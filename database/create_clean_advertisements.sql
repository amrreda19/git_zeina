-- إنشاء جدول إعلانات نظيف وبسيط - للمستخدم الوحيد
-- هذا الحل يحل مشكلة "لم يتم العثور على ملف المستخدم" نهائياً

-- ===== 1. حذف الجداول القديمة المعقدة =====

-- حذف الجداول القديمة التي تحتوي على مشاكل
DROP TABLE IF EXISTS advertisement_stats CASCADE;
DROP TABLE IF EXISTS advertisement_requests CASCADE;
DROP TABLE IF EXISTS advertisement_pricing CASCADE;
DROP TABLE IF EXISTS advertisements CASCADE;

-- ===== 2. إنشاء جدول الإعلانات الجديد والبسيط =====

CREATE TABLE advertisements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- معلومات أساسية
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    link_url TEXT,
    
    -- نوع وموقع الإعلان
    ad_type VARCHAR(50) NOT NULL DEFAULT 'featured' 
        CHECK (ad_type IN ('featured', 'recommended', 'banner')),
    position VARCHAR(50) NOT NULL DEFAULT 'homepage_featured' 
        CHECK (position IN ('homepage_featured', 'homepage_recommended', 'category_featured', 'sidebar')),
    
    -- حالة الإعلان
    is_active BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 1,
    
    -- تواريخ
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    
    -- أوقات الإنشاء والتحديث
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== 3. إنشاء الفهارس الأساسية =====

CREATE INDEX idx_advertisements_type ON advertisements(ad_type);
CREATE INDEX idx_advertisements_position ON advertisements(position);
CREATE INDEX idx_advertisements_active ON advertisements(is_active);
CREATE INDEX idx_advertisements_priority ON advertisements(priority);
CREATE INDEX idx_advertisements_created_at ON advertisements(created_at);

-- ===== 4. إنشاء دالة تحديث وقت التعديل =====

CREATE OR REPLACE FUNCTION update_advertisements_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===== 5. إنشاء trigger لتحديث وقت التعديل =====

CREATE TRIGGER update_advertisements_updated_at_trigger
    BEFORE UPDATE ON advertisements
    FOR EACH ROW
    EXECUTE FUNCTION update_advertisements_updated_at();

-- ===== 6. إضافة بيانات تجريبية =====

-- إعلان تجريبي للصفحة الرئيسية
INSERT INTO advertisements (title, description, ad_type, position, priority) VALUES
('إعلان تجريبي للصفحة الرئيسية', 'هذا إعلان تجريبي للاختبار', 'featured', 'homepage_featured', 1);

-- إعلان تجريبي للشريط الجانبي
INSERT INTO advertisements (title, description, ad_type, position, priority) VALUES
('إعلان تجريبي للشريط الجانبي', 'هذا إعلان تجريبي للاختبار', 'banner', 'sidebar', 2);

-- ===== 7. رسالة تأكيد =====

SELECT 
    'تم إنشاء جدول الإعلانات الجديد بنجاح' AS result,
    COUNT(*) AS total_advertisements
FROM advertisements;
