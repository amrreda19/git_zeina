# تحديث سلوك زر "أضف منتج / إرسال منتج" عبر صفحات التصنيفات

## المطلوب
تحديث سلوك زر "أضف منتج" في جميع صفحات التصنيفات بحيث:
1. عند الضغط على الزر، ينتقل المستخدم إلى الصفحة الرئيسية
2. بعد تحميل الصفحة الرئيسية، يتم التمرير تلقائياً إلى نموذج "رسالة طلب" (قسم الفورم)

## التغييرات المطبقة

### 1. تحديث صفحات التصنيفات
تم تحديث جميع صفحات التصنيفات التالية:
- `pages/category-mirr.html`
- `pages/category-koshat.html`
- `pages/category-cake.html`
- `pages/category-other.html`
- `pages/category-invitations.html`

#### التغييرات في كل صفحة:
- **زر أضف منتج في الهيدر (Desktop)**: تم تغيير `onclick="scrollToProductRequestSection()"` إلى `href="../index.html?scroll=product-request"`
- **زر أضف منتج في الهيدر (Mobile)**: تم تغيير `onclick="scrollToProductRequestSection()"` إلى `href="../index.html?scroll=product-request"`
- **رابط أضف منتج في القائمة المتحركة**: تم تغيير `onclick="scrollToProductRequestSection()"` إلى `href="../index.html?scroll=product-request"`

### 2. تحديث الصفحة الرئيسية
تم إضافة الكود التالي في `index.html`:

#### دالة التمرير التلقائي:
```javascript
function autoScrollToProductRequest() {
    // التحقق من وجود معامل scroll في URL
    const urlParams = new URLSearchParams(window.location.search);
    const scrollParam = urlParams.get('scroll');
    
    if (scrollParam === 'product-request') {
        // إزالة المعامل من URL لتجنب التمرير التلقائي عند تحديث الصفحة
        const newUrl = window.location.pathname;
        window.history.replaceState({}, document.title, newUrl);
        
        // انتظار تحميل الصفحة بالكامل ثم التمرير
        setTimeout(() => {
            const productRequestSection = document.getElementById('product-request-section');
            if (productRequestSection) {
                // التمرير السلس إلى القسم
                productRequestSection.scrollIntoView({ 
                    behavior: 'smooth',
                    block: 'start'
                });
                
                // إضافة تأثير بصري للفت الانتباه
                productRequestSection.style.transition = 'all 0.3s ease';
                productRequestSection.style.boxShadow = '0 0 20px rgba(212, 175, 55, 0.3)';
                
                // إزالة التأثير بعد ثانيتين
                setTimeout(() => {
                    productRequestSection.style.boxShadow = '';
                }, 2000);
            }
        }, 500);
    }
}
```

#### تشغيل الدالة:
```javascript
document.addEventListener('DOMContentLoaded', function() {
    autoScrollToProductRequest();
});
```

## آلية العمل

### 1. الانتقال إلى الصفحة الرئيسية
عند الضغط على زر "أضف منتج" من أي صفحة تصنيفات:
- يتم الانتقال إلى `../index.html?scroll=product-request`
- المعامل `scroll=product-request` يدل على الحاجة للتمرير التلقائي

### 2. التمرير التلقائي
عند تحميل الصفحة الرئيسية:
- يتم قراءة معامل URL `scroll`
- إذا كان القيمة `product-request`، يتم:
  - إزالة المعامل من URL
  - التمرير السلس إلى قسم `#product-request-section`
  - إضافة تأثير بصري (ظل ذهبي) للفت الانتباه
  - إزالة التأثير بعد ثانيتين

## المميزات

### 1. تجربة مستخدم محسنة
- انتقال سلس بين الصفحات
- تمرير تلقائي إلى النموذج المطلوب
- تأثير بصري يجذب الانتباه

### 2. تنظيف URL
- إزالة المعامل بعد التمرير
- تجنب التمرير التلقائي عند تحديث الصفحة

### 3. أداء محسن
- انتظار تحميل الصفحة بالكامل قبل التمرير
- استخدام `scrollIntoView` مع `behavior: 'smooth'`

## الاختبار

### 1. اختبار من صفحات التصنيفات
- انتقل إلى أي صفحة تصنيفات
- اضغط على زر "أضف منتج" (في الهيدر أو القائمة المتحركة)
- تأكد من الانتقال إلى الصفحة الرئيسية
- تأكد من التمرير التلقائي إلى نموذج "رسالة طلب"

### 2. اختبار التأثير البصري
- تأكد من ظهور الظل الذهبي حول النموذج
- تأكد من اختفاء الظل بعد ثانيتين

### 3. اختبار تنظيف URL
- تأكد من إزالة `?scroll=product-request` من URL
- تأكد من عدم التمرير التلقائي عند تحديث الصفحة

## ملاحظات تقنية

### 1. التوافق
- يعمل مع جميع المتصفحات الحديثة
- يستخدم `scrollIntoView` مع `behavior: 'smooth'`
- يستخدم `URLSearchParams` لقراءة معاملات URL

### 2. الأداء
- تأخير 500ms للتأكد من تحميل الصفحة
- تأثير بصري محدود زمنياً (2 ثانية)
- تنظيف URL لتجنب التكرار

### 3. الصيانة
- كود واضح ومنظم
- تعليقات توضيحية باللغة العربية
- سهولة التعديل والتطوير المستقبلي
