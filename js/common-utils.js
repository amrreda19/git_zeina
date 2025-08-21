// Common utilities for the application

// Wait for ProductService to be loaded
function waitForProductService() {
    return new Promise((resolve) => {
        if (window.ProductService && window.supabaseClient) {
            console.log('✅ ProductService and Supabase already loaded');
            resolve(window.ProductService);
        } else {
            console.log('⏳ Waiting for ProductService and Supabase to load...');
            const checkInterval = setInterval(() => {
                if (window.ProductService && window.supabaseClient) {
                    clearInterval(checkInterval);
                    console.log('✅ ProductService and Supabase loaded successfully');
                    resolve(window.ProductService);
                }
            }, 100);
            
            // Timeout after 5 seconds
            setTimeout(() => {
                clearInterval(checkInterval);
                console.error('❌ ProductService or Supabase not loaded after 5 seconds');
                resolve(null);
            }, 5000);
        }
    });
}

// Check if all required services are loaded
function checkRequiredServices() {
    const services = {
        'Supabase': typeof window.supabaseClient !== 'undefined',
        'ProductService': typeof window.ProductService !== 'undefined',
        'ProductService.addProduct': typeof window.ProductService?.addProduct === 'function',
        'ProductService.supabase': typeof window.ProductService?.supabase !== 'undefined'
    };
    
    console.log('🔍 Checking required services:', services);
    
    // Check if all services are available
    const allAvailable = Object.values(services).every(available => available);
    if (!allAvailable) {
        console.error('❌ Some required services are not available:', services);
    }
    
    return services;
}

// Show error message
function showError(message) {
    console.error('❌ Error:', message);
    
    // Create error notification
    const errorDiv = document.createElement('div');
    errorDiv.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg z-50';
    errorDiv.innerHTML = `
        <div class="flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            ${message}
        </div>
    `;
    document.body.appendChild(errorDiv);
    
    // Remove after 5 seconds
    setTimeout(() => {
        errorDiv.remove();
    }, 5000);
}

// Show success message
function showSuccess(message) {
    console.log('✅ Success:', message);
    
    // Create success notification
    const successDiv = document.createElement('div');
    successDiv.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50';
    successDiv.innerHTML = `
        <div class="flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            ${message}
        </div>
    `;
    document.body.appendChild(successDiv);
    
    // Remove after 3 seconds
    setTimeout(() => {
        successDiv.remove();
    }, 3000);
}

// Make functions globally available
window.waitForProductService = waitForProductService;
window.checkRequiredServices = checkRequiredServices;
window.showError = showError;
window.showSuccess = showSuccess;

console.log('🔧 Common utilities loaded'); 