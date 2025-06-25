module.exports = {
    env: {
        browser: true,
        es2021: true,
        node: true,
    },
    extends: [
        'eslint:recommended',
        'plugin:vue/vue3-recommended',
        'prettier'
    ],
    parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
    },
    plugins: ['vue'],
    rules: {
        'vue/multi-word-component-names': 'off',
        'vue/no-unused-vars': 'error',
        'vue/no-unused-components': 'error',
        'no-unused-vars': 'error',
        'no-console': 'warn',
        'no-debugger': 'error',
        'prefer-const': 'error',
        'no-var': 'error',
        'object-shorthand': 'error',
        'prefer-template': 'error',
    },
    globals: {
        // Laravel globals
        route: 'readonly',
        __: 'readonly',
        trans: 'readonly',
        trans_choice: 'readonly',
        // Vite globals
        import: 'readonly',
        // Alpine.js globals
        Alpine: 'readonly',
        // Vue.js globals
        Vue: 'readonly',
    },
}; 