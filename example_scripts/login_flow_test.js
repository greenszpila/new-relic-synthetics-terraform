/**
 * New Relic Synthetic Monitor - Login Flow Test
 *
 * This script tests a complete login workflow:
 * - Navigate to login page
 * - Enter credentials
 * - Submit form
 * - Verify successful login
 */

// Configuration
const BASE_URL = 'https://app.example.com';
const LOGIN_URL = BASE_URL + '/login';
const TEST_USER = $secure.TEST_USERNAME;  // Use secure credentials
const TEST_PASS = $secure.TEST_PASSWORD;
const TIMEOUT = 10000;

// Navigate to login page
$browser.get(LOGIN_URL)
  .then(function() {
    console.log('✓ Navigated to login page');

    // Wait for login form to be visible
    return $browser.wait(
      $driver.until.elementLocated($driver.By.id('username')),
      TIMEOUT,
      'Login form not found'
    );
  })
  .then(function() {
    console.log('✓ Login form loaded');

    // Enter username
    return $browser.findElement($driver.By.id('username')).sendKeys(TEST_USER);
  })
  .then(function() {
    console.log('✓ Entered username');

    // Enter password
    return $browser.findElement($driver.By.id('password')).sendKeys(TEST_PASS);
  })
  .then(function() {
    console.log('✓ Entered password');

    // Click login button
    return $browser.findElement($driver.By.css('button[type="submit"]')).click();
  })
  .then(function() {
    console.log('✓ Submitted login form');

    // Wait for redirect to dashboard
    return $browser.wait(
      $driver.until.urlContains('/dashboard'),
      TIMEOUT,
      'Login failed - dashboard not loaded'
    );
  })
  .then(function() {
    console.log('✓ Redirected to dashboard');

    // Verify user is logged in by checking for logout button or user menu
    return $browser.wait(
      $driver.until.elementLocated($driver.By.css('.user-menu')),
      TIMEOUT,
      'User menu not found - login may have failed'
    );
  })
  .then(function() {
    console.log('✓ User menu visible - login successful');

    // Get current URL for verification
    return $browser.getCurrentUrl();
  })
  .then(function(currentUrl) {
    console.log('Current URL: ' + currentUrl);
    console.log('✅ Login flow test completed successfully');
  });
