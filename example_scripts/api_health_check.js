/**
 * New Relic Synthetic Monitor - API Health Check
 *
 * This script checks the health endpoint of an API and validates:
 * - HTTP 200 response
 * - Response time under threshold
 * - JSON response structure
 */

const assert = require('assert');

// Configuration
const API_URL = 'https://api.example.com/health';
const TIMEOUT_MS = 5000;
const MAX_RESPONSE_TIME_MS = 2000;

// Make GET request to health endpoint
$http.get(
  {
    url: API_URL,
    timeout: TIMEOUT_MS,
    headers: {
      'User-Agent': 'New Relic Synthetic Monitor',
      'Accept': 'application/json'
    }
  },
  function(err, response, body) {
    // Check for request errors
    assert.ok(!err, 'Request failed: ' + err);

    // Validate status code
    assert.equal(response.statusCode, 200, 'Expected HTTP 200, got: ' + response.statusCode);

    // Validate response time
    const responseTime = response.timings.response;
    assert.ok(
      responseTime < MAX_RESPONSE_TIME_MS,
      'Response time too slow: ' + responseTime + 'ms (threshold: ' + MAX_RESPONSE_TIME_MS + 'ms)'
    );

    // Parse and validate JSON response
    let healthData;
    try {
      healthData = JSON.parse(body);
    } catch (e) {
      assert.fail('Invalid JSON response: ' + e.message);
    }

    // Validate required fields
    assert.ok(healthData.status, 'Missing "status" field in response');
    assert.equal(healthData.status, 'healthy', 'Service not healthy: ' + healthData.status);

    console.log('✓ Health check passed');
    console.log('Response time: ' + responseTime + 'ms');
    console.log('Status: ' + healthData.status);
  }
);
