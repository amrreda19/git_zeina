-- 🔧 إصلاح صلاحيات جدول بوكيهات الورد - إصلاح مشكلة الحذف
-- تنفيذ هذه الأوامر في Supabase SQL Editor

-- 1. التحقق من وجود الجدول
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'products_flowerbouquets'
);

-- 2. إزالة جميع السياسات الموجودة
DROP POLICY IF EXISTS "Allow delete for authenticated users" ON products_flowerbouquets;
DROP POLICY IF EXISTS "Allow read for authenticated users" ON products_flowerbouquets;
DROP POLICY IF EXISTS "Allow update for authenticated users" ON products_flowerbouquets;
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON products_flowerbouquets;

-- 3. إزالة RLS مؤقتاً
ALTER TABLE products_flowerbouquets DISABLE ROW LEVEL SECURITY;

-- 4. منح صلاحيات كاملة للمستخدمين المصادق عليهم
GRANT ALL PRIVILEGES ON TABLE products_flowerbouquets TO authenticated;
GRANT ALL PRIVILEGES ON TABLE products_flowerbouquets TO anon;

-- 5. إنشاء سياسات جديدة تسمح بالحذف
CREATE POLICY "Enable all operations for authenticated users" ON products_flowerbouquets
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all operations for anon users" ON products_flowerbouquets
    FOR ALL TO anon USING (true) WITH CHECK (true);

-- 6. إعادة تفعيل RLS مع السياسات الجديدة
ALTER TABLE products_flowerbouquets ENABLE ROW LEVEL SECURITY;

-- 7. التحقق من النتيجة
SELECT 
    tablename,
    rowsecurity,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'products_flowerbouquets') as policies_count
FROM pg_tables 
WHERE tablename = 'products_flowerbouquets';

-- 8. فحص الصلاحيات بعد الإصلاح
SELECT grantee, privilege_type, is_grantable
FROM information_schema.role_table_grants 
WHERE table_name = 'products_flowerbouquets';

-- 9. اختبار الحذف (تنفيذ في console المتصفح)
-- const { data, error } = await supabase
--     .from('products_flowerbouquets')
--     .delete()
--     .eq('id', [PRODUCT_ID])
--     .select();
-- console.log('Delete test:', { data, error });
