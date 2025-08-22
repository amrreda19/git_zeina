-- إنشاء جدول منتجات المرايا
-- هذا الجدول مطلوب لعرض منتجات المرايا في صفحة المرايا

-- ===== 1. إنشاء جدول منتجات المرايا =====

CREATE TABLE IF NOT EXISTS public.products_mirr (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0,
    location TEXT,
    governorate TEXT,
    cities TEXT,
    subcategory TEXT,
    images TEXT[], -- مصفوفة من روابط الصور
    user_id UUID,
    contact_phone TEXT,
    contact_email TEXT,
    is_negotiable BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    status TEXT DEFAULT 'active',
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== 2. إضافة الفهارس لتحسين الأداء =====

-- فهرس على user_id للبحث السريع
CREATE INDEX IF NOT EXISTS idx_products_mirr_user_id ON public.products_mirr(user_id);

-- فهرس على status للبحث السريع
CREATE INDEX IF NOT EXISTS idx_products_mirr_status ON public.products_mirr(status);

-- فهرس على created_at للترتيب
CREATE INDEX IF NOT EXISTS idx_products_mirr_created_at ON public.products_mirr(created_at);

-- فهرس على price للبحث السريع
CREATE INDEX IF NOT EXISTS idx_products_mirr_price ON public.products_mirr(price);

-- فهرس على governorate للبحث السريع
CREATE INDEX IF NOT EXISTS idx_products_mirr_governorate ON public.products_mirr(governorate);

-- فهرس على subcategory للبحث السريع
CREATE INDEX IF NOT EXISTS idx_products_mirr_subcategory ON public.products_mirr(subcategory);

-- ===== 3. إضافة تعليقات على الجدول =====

COMMENT ON TABLE public.products_mirr IS 'جدول منتجات المرايا';
COMMENT ON COLUMN public.products_mirr.title IS 'عنوان المنتج';
COMMENT ON COLUMN public.products_mirr.description IS 'وصف المنتج';
COMMENT ON COLUMN public.products_mirr.price IS 'سعر المنتج';
COMMENT ON COLUMN public.products_mirr.location IS 'موقع المنتج';
COMMENT ON COLUMN public.products_mirr.governorate IS 'المحافظة';
COMMENT ON COLUMN public.products_mirr.cities IS 'المدن/المناطق';
COMMENT ON COLUMN public.products_mirr.subcategory IS 'الفئة الفرعية';
COMMENT ON COLUMN public.products_mirr.images IS 'مصفوفة من روابط الصور';
COMMENT ON COLUMN public.products_mirr.user_id IS 'معرف المستخدم';
COMMENT ON COLUMN public.products_mirr.contact_phone IS 'رقم الهاتف للتواصل';
COMMENT ON COLUMN public.products_mirr.contact_email IS 'البريد الإلكتروني للتواصل';
COMMENT ON COLUMN public.products_mirr.is_negotiable IS 'هل السعر قابل للتفاوض';
COMMENT ON COLUMN public.products_mirr.is_featured IS 'هل المنتج مميز';
COMMENT ON COLUMN public.products_mirr.status IS 'حالة المنتج';
COMMENT ON COLUMN public.products_mirr.views_count IS 'عدد المشاهدات';
COMMENT ON COLUMN public.products_mirr.created_at IS 'تاريخ الإنشاء';
COMMENT ON COLUMN public.products_mirr.updated_at IS 'تاريخ آخر تحديث';

-- ===== 4. إضافة RLS (Row Level Security) إذا كان مطلوباً =====

-- تفعيل RLS على الجدول
ALTER TABLE public.products_mirr ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسة للسماح للجميع برؤية المنتجات النشطة
CREATE POLICY "Anyone can view active products" ON public.products_mirr
    FOR SELECT USING (status = 'active');

-- إنشاء سياسة للسماح للمستخدمين بإضافة منتجاتهم
CREATE POLICY "Users can insert their own products" ON public.products_mirr
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- إنشاء سياسة للسماح للمستخدمين بتحديث منتجاتهم
CREATE POLICY "Users can update their own products" ON public.products_mirr
    FOR UPDATE USING (auth.uid() = user_id);

-- إنشاء سياسة للسماح للمستخدمين بحذف منتجاتهم
CREATE POLICY "Users can delete their own products" ON public.products_mirr
    FOR DELETE USING (auth.uid() = user_id);

-- ===== 5. إضافة بيانات تجريبية (اختياري) =====

-- إضافة منتج تجريبي للمرايا
INSERT INTO public.products_mirr (
    title, 
    description, 
    price, 
    location, 
    governorate, 
    cities, 
    subcategory, 
    images,
    user_id,
    contact_phone,
    contact_email,
    is_negotiable,
    status
) VALUES (
    'مرآة مزخرفة كلاسيكية',
    'مرآة مزخرفة بتصميم كلاسيكي أنيق، مثالية للديكورات والمناسبات',
    450.00,
    'القاهرة',
    'القاهرة',
    'المعادي,مصر الجديدة',
    'مرايا كلاسيكية',
    ARRAY['https://example.com/mirror1.jpg', 'https://example.com/mirror2.jpg'],
    '00000000-0000-0000-0000-000000000000', -- user_id تجريبي
    '+201234567890',
    'test@example.com',
    true,
    'active'
) ON CONFLICT DO NOTHING;

-- ===== 6. رسالة تأكيد =====

SELECT 
    'تم إنشاء جدول منتجات المرايا بنجاح' AS result,
    'products_mirr' AS table_name,
    'public' AS schema_name,
    COUNT(*) AS sample_products_count
FROM public.products_mirr;
