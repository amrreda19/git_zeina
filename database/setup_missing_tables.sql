-- إعداد الجداول المفقودة لحل مشاكل صفحة المرايا
-- هذا الملف يحل مشكلتين:
-- 1. جدول المفضلات المفقود (favorites)
-- 2. جدول منتجات المرايا المفقود (products_mirr)

-- ===== 1. إنشاء جدول المفضلات =====

CREATE TABLE IF NOT EXISTS public.favorites (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    product_id INTEGER NOT NULL,
    product_table VARCHAR(50) NOT NULL, -- اسم الجدول الذي يحتوي على المنتج
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- فهارس لجدول المفضلات
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_product_id ON public.favorites(product_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_user_product_unique 
ON public.favorites(user_id, product_id, product_table);

-- ===== 2. إنشاء جدول منتجات المرايا =====

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

-- فهارس لجدول منتجات المرايا
CREATE INDEX IF NOT EXISTS idx_products_mirr_user_id ON public.products_mirr(user_id);
CREATE INDEX IF NOT EXISTS idx_products_mirr_status ON public.products_mirr(status);
CREATE INDEX IF NOT EXISTS idx_products_mirr_created_at ON public.products_mirr(created_at);
CREATE INDEX IF NOT EXISTS idx_products_mirr_price ON public.products_mirr(price);
CREATE INDEX IF NOT EXISTS idx_products_mirr_governorate ON public.products_mirr(governorate);
CREATE INDEX IF NOT EXISTS idx_products_mirr_subcategory ON public.products_mirr(subcategory);

-- ===== 3. إضافة تعليقات على الجداول =====

COMMENT ON TABLE public.favorites IS 'جدول المفضلات للمستخدمين';
COMMENT ON TABLE public.products_mirr IS 'جدول منتجات المرايا';

-- ===== 4. إضافة RLS (Row Level Security) =====

-- تفعيل RLS على جدول المفضلات
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- سياسات جدول المفضلات
CREATE POLICY "Users can view their own favorites" ON public.favorites
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own favorites" ON public.favorites
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own favorites" ON public.favorites
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own favorites" ON public.favorites
    FOR DELETE USING (auth.uid() = user_id);

-- تفعيل RLS على جدول منتجات المرايا
ALTER TABLE public.products_mirr ENABLE ROW LEVEL SECURITY;

-- سياسات جدول منتجات المرايا
CREATE POLICY "Anyone can view active products" ON public.products_mirr
    FOR SELECT USING (status = 'active');
CREATE POLICY "Users can insert their own products" ON public.products_mirr
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own products" ON public.products_mirr
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own products" ON public.products_mirr
    FOR DELETE USING (auth.uid() = user_id);

-- ===== 5. إضافة بيانات تجريبية للمرايا =====

-- إضافة منتجات تجريبية للمرايا
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
) VALUES 
(
    'مرآة مزخرفة كلاسيكية',
    'مرآة مزخرفة بتصميم كلاسيكي أنيق، مثالية للديكورات والمناسبات',
    450.00,
    'القاهرة',
    'القاهرة',
    'المعادي,مصر الجديدة',
    'مرايا كلاسيكية',
    ARRAY['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'],
    '00000000-0000-0000-0000-000000000000',
    '+201234567890',
    'test@example.com',
    true,
    'active'
),
(
    'مرآة عصرية بسيطة',
    'مرآة عصرية بتصميم بسيط وأنيق، مناسبة لجميع أنواع الديكورات',
    320.00,
    'الإسكندرية',
    'الإسكندرية',
    'سموحة,سيدي جابر',
    'مرايا عصرية',
    ARRAY['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'],
    '00000000-0000-0000-0000-000000000000',
    '+201234567891',
    'test2@example.com',
    false,
    'active'
),
(
    'مرآة فاخرة للقصور',
    'مرآة فاخرة بتصميم ملكي، مثالية للقصور والمناسبات الكبيرة',
    1200.00,
    'الجيزة',
    'الجيزة',
    'الدقي,المهندسين',
    'مرايا فاخرة',
    ARRAY['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'],
    '00000000-0000-0000-0000-000000000000',
    '+201234567892',
    'test3@example.com',
    true,
    'active'
) ON CONFLICT DO NOTHING;

-- ===== 6. رسالة تأكيد =====

SELECT 
    'تم إعداد الجداول المفقودة بنجاح' AS result,
    'favorites' AS favorites_table,
    'products_mirr' AS products_table,
    COUNT(*) AS sample_products_count
FROM public.products_mirr;
