/*
Specifies the paths to all of your view modules, template files, and JavaScript files that contain 
Tailwind class names. To do that, set the content option in the tailwind.config.js
*/
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {},
  variants: {},
  plugins: []
};
