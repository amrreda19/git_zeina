# دليل خدمة رفع الصور المتقدمة

## نظرة عامة

خدمة `AdvancedImageUploadService` هي خدمة شاملة لرفع الصور إلى Supabase مع معالجة متقدمة تشمل التحقق من الحجم، التصغير التلقائي، الضغط، وإدارة الأخطاء.

## الميزات

✅ **التحقق من حجم الملف**: فحص تلقائي لحجم الصورة قبل المعالجة
✅ **التصغير التلقائي**: تصغير الصور الكبيرة مع الحفاظ على النسبة
✅ **الضغط الذكي**: ضغط الصور دون فقدان جودة كبيرة
✅ **أسماء فريدة**: إنشاء أسماء ملفات فريدة لتجنب التعارض
✅ **رفع متعدد**: دعم رفع عدة صور في وقت واحد
✅ **إدارة الأخطاء**: معالجة شاملة للأخطاء والاستثناءات
✅ **عرض التقدم**: مؤشر تقدم لعمليات الرفع
✅ **URLs عامة**: إرجاع روابط عامة للصور المرفوعة
✅ **ضغط تلقائي دائم**: ضغط جميع الصور افتراضياً لتحسين الأداء
✅ **ضغط عدواني**: ضغط متقدم للملفات الكبيرة جداً
✅ **إحصائيات مفصلة**: عرض نسب الضغط وحجم المساحة الموفرة

## التثبيت والإعداد

### 1. تضمين الملفات المطلوبة

```html
<!-- Supabase Library -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

<!-- ملف إعداد Supabase -->
<script src="js/supabase-config.js"></script>

<!-- خدمة رفع الصور المتقدمة -->
<script src="js/advanced-image-upload-service.js"></script>
```

### 2. تهيئة الخدمة

```javascript
// تهيئة الخدمة بالإعدادات الافتراضية
const imageUploadService = new AdvancedImageUploadService();

// أو مع إعدادات مخصصة
const imageUploadService = new AdvancedImageUploadService({
    maxFileSize: 1024 * 1024,        // 1MB
    maxWidth: 1200,                  // أقصى عرض
    maxHeight: 1200,                 // أقصى ارتفاع
    quality: 0.8,                    // جودة الضغط
    storageBucket: 'images',         // اسم المجلد في Supabase
    folderPath: 'uploads',           // مسار المجلد الفرعي
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp']
});
```

## طرق الاستخدام

### رفع صورة واحدة

```javascript
// اختيار الملف من input
const fileInput = document.getElementById('fileInput');
fileInput.addEventListener('change', async (e) => {
    const file = e.target.files[0];

    try {
        const result = await imageUploadService.uploadImage(file);

        if (result.success) {
            console.log('✅ تم الرفع بنجاح!');
            console.log('🔗 الرابط العام:', result.data.url);
            console.log('📁 المسار:', result.data.path);

            // عرض الصورة
            const img = document.createElement('img');
            img.src = result.data.url;
            document.body.appendChild(img);
        } else {
            console.error('❌ فشل في الرفع:', result.error);
        }
    } catch (error) {
        console.error('❌ خطأ:', error);
    }
});
```

### رفع صور متعددة

```javascript
// اختيار عدة ملفات
const multiFileInput = document.getElementById('multiFileInput');
multiFileInput.addEventListener('change', async (e) => {
    const files = Array.from(e.target.files);

    try {
        const result = await imageUploadService.uploadImages(files);

        if (result.success) {
            console.log(`✅ تم رفع ${result.data.successCount} من ${result.data.totalFiles} صورة`);

            // عرض النتائج
            result.data.uploadedImages.forEach((image, index) => {
                console.log(`صورة ${index + 1}:`, image.url);
            });

            // عرض الأخطاء إن وجدت
            if (result.data.errors) {
                result.data.errors.forEach(error => {
                    console.error(`خطأ في ${error.file}:`, error.error);
                });
            }
        } else {
            console.error('❌ فشل في رفع الصور:', result.error);
        }
    } catch (error) {
        console.error('❌ خطأ:', error);
    }
});
```

### حذف صورة

```javascript
// حذف صورة من التخزين
const deleteResult = await imageUploadService.deleteImage('uploads/1234567890_image.jpg');

if (deleteResult.success) {
    console.log('✅ تم حذف الصورة بنجاح');
} else {
    console.error('❌ فشل في حذف الصورة:', deleteResult.error);
}
```

### الحصول على معلومات الصورة

```javascript
// الحصول على معلومات الصورة قبل الرفع
const metadata = await imageUploadService.getImageMetadata(file);
console.log('📏 الأبعاد:', metadata.width, 'x', metadata.height);
console.log('📊 الحجم:', metadata.fileSize);
console.log('📋 النوع:', metadata.fileType);
```

## إعدادات التخصيص

| الخيار | النوع | الافتراضي | الوصف |
|--------|-------|-----------|--------|
| `maxFileSize` | Number | 1048576 (1MB) | الحد الأقصى لحجم الملف بالبايت |
| `maxWidth` | Number | 1200 | الحد الأقصى للعرض بالبكسل |
| `maxHeight` | Number | 1200 | الحد الأقصى للارتفاع بالبكسل |
| `quality` | Number | 0.85 | جودة الضغط (0-1) |
| `storageBucket` | String | 'images' | اسم مجلد Supabase Storage |
| `folderPath` | String | 'uploads' | المسار الفرعي داخل المجلد |
| `allowedTypes` | Array | ['image/jpeg', 'image/png', 'image/webp'] | أنواع الملفات المسموحة |
| `alwaysCompress` | Boolean | true | ضغط جميع الصور دائماً (موصى به) |

## معالجة الأخطاء

```javascript
try {
    const result = await imageUploadService.uploadImage(file);

    if (result.success) {
        // نجح الرفع
        handleSuccess(result.data);
    } else {
        // فشل الرفع - عرض رسالة الخطأ
        handleError(result.error);
    }
} catch (error) {
    // خطأ غير متوقع
    handleUnexpectedError(error);
}
```

## أنواع الأخطاء الشائعة

- **"No file provided"**: لم يتم تقديم ملف
- **"Unsupported file type"**: نوع الملف غير مدعوم
- **"File too large"**: حجم الملف كبير جداً
- **"AdvancedImageUploadService not initialized"**: الخدمة غير مهيأة
- **"Upload failed"**: فشل في الرفع إلى Supabase
- **"Failed to get public URL"**: فشل في الحصول على الرابط العام

## التكامل مع نموذج طلب المنتج

تم تطبيق الخدمة على صفحة `add-product-request.html` مع التحسينات التالية:

### الميزات المضافة:
- ✅ **ضغط تلقائي دائم** لجميع الصور المرفوعة
- ✅ **عرض إحصائيات الضغط** لكل صورة على حدة
- ✅ **ملخص إحصائيات الضغط الإجمالية** لجميع الصور
- ✅ **واجهة محسنة** تعرض المساحة الموفرة
- ✅ **تنظيف تلقائي** للصور الفاشلة في الرفع

### كيفية عمل التكامل:

1. **التشغيل التلقائي**: الخدمة تعمل تلقائياً عند تحميل الصفحة
2. **الإعدادات المحسنة**: تستخدم أفضل الإعدادات للضغط
3. **العرض التفاعلي**: تظهر إحصائيات الضغط مباشرة على الصور
4. **المعالجة الشاملة**: تتعامل مع جميع الحالات (نجاح/فشل)

### ملفات الاختبار المتاحة:

1. **`js/quick-test.html`** - اختبار سريع بسيط
2. **`js/test-image-compression.html`** - اختبار شامل للضغط
3. **`js/test-product-request-form.html`** - اختبار نموذج الطلب
4. **`js/image-upload-example.html`** - مثال تفاعلي مع واجهة

## مثال كامل للتكامل

```html
<!DOCTYPE html>
<html>
<head>
    <title>رفع الصور</title>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="js/supabase-config.js"></script>
    <script src="js/advanced-image-upload-service.js"></script>
</head>
<body>
    <input type="file" id="imageInput" accept="image/*" multiple>
    <button id="uploadBtn">رفع الصور</button>
    <div id="results"></div>

    <script>
        document.addEventListener('DOMContentLoaded', async () => {
            // استخدام الإعدادات المحسنة مثل صفحة الاختبار
            const imageUploadService = new AdvancedImageUploadService({
                maxFileSize: 1024 * 1024, // 1MB
                maxWidth: 1200,
                maxHeight: 1200,
                quality: 0.85, // جودة أعلى
                alwaysCompress: true, // ضغط دائم
                folderPath: 'uploads'
            });

            const imageInput = document.getElementById('imageInput');
            const uploadBtn = document.getElementById('uploadBtn');
            const results = document.getElementById('results');

            uploadBtn.addEventListener('click', async () => {
                const files = Array.from(imageInput.files);
                if (files.length === 0) return;

                results.innerHTML = 'جاري الرفع والضغط...';

                const result = await imageUploadService.uploadImages(files);

                if (result.success) {
                    results.innerHTML = `
                        <h3>✅ تم رفع ${result.data.successCount} صورة بنجاح!</h3>
                        <div style="background: #e9ecef; padding: 15px; border-radius: 5px; margin: 10px 0;">
                            <h4>📊 إحصائيات الضغط:</h4>
                            <ul>
                                <li>المساحة الموفرة: ${formatBytes(result.data.uploadedImages.reduce((sum, img) => sum + (img.originalSize - img.processedSize), 0))}</li>
                                <li>متوسط الضغط: ${(result.data.uploadedImages.reduce((sum, img) => sum + parseFloat(img.compressionRatio), 0) / result.data.uploadedImages.length).toFixed(1)}%</li>
                            </ul>
                        </div>
                        ${result.data.uploadedImages.map(img => `
                            <div style="border: 1px solid #ddd; padding: 10px; margin: 5px; border-radius: 5px;">
                                <img src="${img.url}" style="max-width: 200px;">
                                <p>الحجم الأصلي: ${formatBytes(img.originalSize)} → الحجم المعالج: ${formatBytes(img.processedSize)} (${img.compressionRatio}%)</p>
                            </div>
                        `).join('')}
                    `;
                } else {
                    results.innerHTML = `<p style="color: red;">❌ خطأ: ${result.error}</p>`;
                }
            });
        });

        function formatBytes(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }
    </script>
</body>
</html>
```

## ملاحظات مهمة

1. **تأكد من تحميل Supabase** قبل استخدام الخدمة
2. **تحقق من الأذونات** في Supabase Storage
3. **استخدم HTTPS** في الإنتاج لضمان أمان البيانات
4. **راقب استخدام التخزين** لتجنب تجاوز الحدود
5. **اختبر الخدمة** في بيئة التطوير قبل النشر

## الدعم والمساعدة

للمساعدة أو الإبلاغ عن مشاكل، تحقق من:
- وحدة التحكم في المتصفح للأخطاء
- إعدادات Supabase Storage
- أذونات الوصول للمجلدات
