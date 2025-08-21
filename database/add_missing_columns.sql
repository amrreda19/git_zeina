-- إضافة الأعمدة المفقودة لجدول الإعلانات
-- هذا الملف يضيف الأعمدة التي يحتاجها الكود

-- ===== 1. إضافة الأعمدة المفقودة =====

-- إضافة عمود title إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS title TEXT;

-- إضافة عمود description إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS description TEXT;

-- إضافة عمود image_url إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS image_url TEXT;

-- إضافة عمود link_url إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS link_url TEXT;

-- إضافة عمود impressions_count إذا لم يكن موجوداً
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS impressions_count INTEGER DEFAULT 0;

-- ===== 2. تحديث البيانات الموجودة =====

-- تحديث الإعلانات الموجودة لتكون لها عنوان
UPDATE advertisements 
SET title = COALESCE(title, 'إعلان ' || id::text)
WHERE title IS NULL;

-- ===== 3. رسالة تأكيد =====

SELECT 
    'تم إضافة الأعمدة المفقودة بنجاح' AS result,
    COUNT(*) AS total_advertisements
FROM advertisements;
