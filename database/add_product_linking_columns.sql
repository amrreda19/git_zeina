-- إضافة أعمدة ربط المنتجات بالإعلانات
-- هذا الملف يضيف الأعمدة المطلوبة لربط الإعلانات بالمنتجات الحقيقية

-- ===== 1. إضافة أعمدة ربط المنتجات =====

-- إضافة عمود product_id إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS product_id UUID;

-- إضافة عمود product_category إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS product_category VARCHAR(50);

-- إضافة عمود clicks_count إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS clicks_count INTEGER DEFAULT 0;

-- ===== 2. إنشاء فهارس لتحسين الأداء =====

-- فهرس على product_id
CREATE INDEX IF NOT EXISTS idx_advertisements_product_id ON advertisements(product_id);

-- فهرس على product_category
CREATE INDEX IF NOT EXISTS idx_advertisements_product_category ON advertisements(product_category);

-- فهرس مركب على product_id و product_category
CREATE INDEX IF NOT EXISTS idx_advertisements_product_linking ON advertisements(product_id, product_category);

-- ===== 3. تحديث البيانات الموجودة =====

-- تحديث الإعلانات الموجودة لتكون مرتبطة بمنتجات تجريبية (اختياري)
-- يمكنك حذف هذا الجزء إذا كنت تريد إضافة الإعلانات يدوياً

-- ===== 4. رسالة تأكيد =====

SELECT 
    'تم إضافة أعمدة ربط المنتجات بنجاح' AS result,
    COUNT(*) AS total_advertisements,
    COUNT(CASE WHEN product_id IS NOT NULL THEN 1 END) AS linked_ads,
    COUNT(CASE WHEN product_id IS NULL THEN 1 END) AS unlinked_ads
FROM advertisements;
