/**
 * New Relic Synthetic Monitor - API POST with Authentication
 *
 * This script demonstrates:
 * - POST request with JSON payload
 * - Bearer token authentication
 * - Response validation
 * - Error handling
 */

const assert = require('assert');

// Configuration
const API_URL = 'https://api.example.com/v1/orders';
const AUTH_TOKEN = $secure.API_TOKEN;  // Store in secure credentials
const TIMEOUT_MS = 10000;

// Test payload
const testOrder = {
  customer_id: 'test-customer-123',
  items: [
    { sku: 'WIDGET-001', quantity: 2 },
    { sku: 'GADGET-002', quantity: 1 }
  ],
  shipping_address: {
    street: '123 Test Street',
    city: 'Dublin',
    country: 'IE',
    postal_code: 'D02 XY45'
  }
};

// Make POST request
$http.post(
  {
    url: API_URL,
    timeout: TIMEOUT_MS,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + AUTH_TOKEN,
      'User-Agent': 'New Relic Synthetic Monitor'
    },
    json: testOrder
  },
  function(err, response, body) {
    // Handle request errors
    if (err) {
      console.error('Request failed:', err);
      assert.fail('HTTP request error: ' + err);
    }

    console.log('Response status:', response.statusCode);
    console.log('Response time:', response.timings.response + 'ms');

    // Validate status code (201 Created expected)
    assert.equal(
      response.statusCode,
      201,
      'Expected HTTP 201, got: ' + response.statusCode
    );

    // Validate response body
    assert.ok(body, 'Response body is empty');

    let orderResponse;
    try {
      orderResponse = typeof body === 'string' ? JSON.parse(body) : body;
    } catch (e) {
      assert.fail('Invalid JSON response: ' + e.message);
    }

    // Validate response structure
    assert.ok(orderResponse.order_id, 'Missing order_id in response');
    assert.ok(orderResponse.status, 'Missing status in response');
    assert.equal(
      orderResponse.status,
      'pending',
      'Unexpected order status: ' + orderResponse.status
    );

    // Validate order details
    assert.equal(
      orderResponse.customer_id,
      testOrder.customer_id,
      'Customer ID mismatch'
    );
    assert.equal(
      orderResponse.items.length,
      testOrder.items.length,
      'Items count mismatch'
    );

    console.log('✓ Order created successfully');
    console.log('Order ID:', orderResponse.order_id);
    console.log('Status:', orderResponse.status);

    // Optional: Clean up test order (DELETE request)
    cleanup(orderResponse.order_id);
  }
);

/**
 * Optional cleanup function to delete test order
 */
function cleanup(orderId) {
  $http.delete(
    {
      url: API_URL + '/' + orderId,
      timeout: 5000,
      headers: {
        'Authorization': 'Bearer ' + AUTH_TOKEN
      }
    },
    function(err, response) {
      if (err) {
        console.warn('Cleanup failed:', err);
        return;
      }

      if (response.statusCode === 204 || response.statusCode === 200) {
        console.log('✓ Test order cleaned up');
      } else {
        console.warn('Cleanup returned status:', response.statusCode);
      }
    }
  );
}
