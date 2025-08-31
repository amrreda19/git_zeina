# 🔧 إصلاح مشكلة حذف المنتجات في بوكيهات الورد

## 📋 المشكلة
المنتجات في صفحة إدارة المنتجات لا تريد أن تحذف في بوكيهات الورد

## 🔍 التشخيص

### 1. فحص قاعدة البيانات
```sql
-- التحقق من وجود جدول بوكيهات الورد
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'products_flowerbouquets'
);

-- فحص هيكل الجدول
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'products_flowerbouquets';

-- فحص الصلاحيات
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'products_flowerbouquets';
```

### 2. فحص الصلاحيات
```sql
-- التحقق من صلاحيات المستخدم الحالي
SELECT current_user, session_user;

-- التحقق من دور المستخدم
SELECT role, status FROM users WHERE id = auth.uid();
```

### 3. فحص RLS (Row Level Security)
```sql
-- التحقق من وجود RLS
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'products_flowerbouquets';

-- فحص السياسات
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'products_flowerbouquets';
```

## 🛠️ الحلول المقترحة

### الحل الأول: إصلاح الصلاحيات
```sql
-- منح صلاحيات كاملة للمستخدم
GRANT ALL PRIVILEGES ON TABLE products_flowerbouquets TO authenticated;
GRANT ALL PRIVILEGES ON TABLE products_flowerbouquets TO anon;

-- إزالة RLS مؤقتاً
ALTER TABLE products_flowerbouquets DISABLE ROW LEVEL SECURITY;

-- أو إنشاء سياسة تسمح بالحذف
CREATE POLICY "Allow delete for authenticated users" ON products_flowerbouquets
    FOR DELETE TO authenticated USING (true);
```

### الحل الثاني: إصلاح الكود
```javascript
// في product-service.js - تحسين دالة الحذف
async deleteProduct(productId, sourceTable = null) {
    try {
        console.log(`🗑️ Starting deletion for product: ${productId}, table: ${sourceTable}`);
        
        // التأكد من التهيئة
        const isReady = await this.ensureInitialized();
        if (!isReady) {
            throw new Error('ProductService not initialized');
        }

        // تحديد الجدول الصحيح
        let tableName = sourceTable;
        if (!tableName) {
            const productResult = await this.getProductById(productId);
            if (!productResult.success) {
                throw new Error('Product not found');
            }
            tableName = productResult.data.source_table;
        }

        // محاولة الحذف مع معالجة أفضل للأخطاء
        const { data, error } = await this.supabase
            .from(tableName)
            .delete()
            .eq('id', productId)
            .select();

        if (error) {
            console.error('Delete error:', error);
            
            // محاولة الحذف الناعم
            if (error.message.includes('permission') || error.message.includes('policy')) {
                console.log('Attempting soft delete...');
                const { data: softDeleteData, error: softDeleteError } = await this.supabase
                    .from(tableName)
                    .update({ 
                        deleted_at: new Date().toISOString(),
                        status: 'محذوف'
                    })
                    .eq('id', productId)
                    .select();

                if (softDeleteError) {
                    throw new Error(`Soft delete failed: ${softDeleteError.message}`);
                }
                
                console.log('Soft delete successful');
                return { success: true, method: 'soft_delete' };
            }
            
            throw error;
        }

        console.log('Hard delete successful');
        return { success: true, method: 'hard_delete' };

    } catch (error) {
        console.error('Delete product error:', error);
        return { success: false, error: error.message };
    }
}
```

### الحل الثالث: إصلاح الواجهة
```javascript
// في admin-products.html - تحسين معالجة الأخطاء
async function confirmDelete() {
    if (!productToDelete) {
        alert('لم يتم تحديد منتج للحذف');
        return;
    }

    try {
        // إظهار مؤشر التحميل
        const deleteBtn = document.querySelector('#deleteModal .btn-delete');
        const originalText = deleteBtn.textContent;
        deleteBtn.textContent = 'جاري الحذف...';
        deleteBtn.disabled = true;

        const result = await window.ProductService.deleteProduct(
            productToDelete.id, 
            productToDelete.table
        );

        if (result.success) {
            alert(`تم حذف المنتج بنجاح (${result.method || 'hard_delete'})`);
            
            // تحديث الصفحة
            await loadAllProducts();
            await loadStatistics();
            applyFilter(currentFilter);
        } else {
            throw new Error(result.error);
        }

    } catch (error) {
        console.error('Delete error:', error);
        
        // رسائل خطأ أكثر وضوحاً
        let errorMessage = 'حدث خطأ في حذف المنتج';
        
        if (error.message.includes('permission')) {
            errorMessage = 'ليس لديك صلاحية لحذف هذا المنتج. يرجى التواصل مع المدير.';
        } else if (error.message.includes('policy')) {
            errorMessage = 'سياسة الأمان تمنع حذف هذا المنتج. يرجى التواصل مع المدير.';
        } else if (error.message.includes('not found')) {
            errorMessage = 'المنتج غير موجود أو تم حذفه مسبقاً.';
        } else {
            errorMessage += `: ${error.message}`;
        }
        
        alert(errorMessage);
    } finally {
        // إعادة تعيين الزر
        const deleteBtn = document.querySelector('#deleteModal .btn-delete');
        deleteBtn.textContent = originalText;
        deleteBtn.disabled = false;
        closeDeleteModal();
    }
}
```

## 🧪 اختبار الحلول

### 1. اختبار الصلاحيات
```javascript
// في console المتصفح
// اختبار الاتصال بقاعدة البيانات
const { data, error } = await supabase
    .from('products_flowerbouquets')
    .select('*')
    .limit(1);

console.log('Connection test:', { data, error });
```

### 2. اختبار الحذف
```javascript
// اختبار حذف منتج تجريبي
const testDelete = await ProductService.deleteProduct('test_id', 'products_flowerbouquets');
console.log('Delete test:', testDelete);
```

## 📝 خطوات التنفيذ

1. **فحص قاعدة البيانات**: تنفيذ أوامر SQL للتشخيص
2. **إصلاح الصلاحيات**: منح الصلاحيات المطلوبة
3. **تحديث الكود**: تطبيق التحسينات المقترحة
4. **اختبار الحل**: التأكد من عمل الحذف
5. **مراقبة الأخطاء**: متابعة console للأخطاء

## 🔒 ملاحظات الأمان

- تأكد من أن المستخدم لديه صلاحيات إدارية
- استخدم الحذف الناعم بدلاً من الحذف المادي عند الإمكان
- سجل جميع عمليات الحذف للتدقيق
- تحقق من صحة البيانات قبل الحذف

## 📞 الدعم

إذا استمرت المشكلة:
1. راجع logs قاعدة البيانات
2. تحقق من إعدادات Supabase
3. تأكد من تحديث المكتبات
4. تواصل مع فريق الدعم التقني
