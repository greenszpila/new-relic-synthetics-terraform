# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

resource "newrelic_synthetics_monitor" "online_boutique_frontend" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1", "EU_WEST_2", "EU_WEST_3"]
  name                                    = "Online Boutique Frontend"
  period                                  = "EVERY_5_MINUTES"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"

  type                                    = "BROWSER"
  uri                                     = "https://3.11.6.175:80"

  verify_ssl                              = false
}

resource "newrelic_synthetics_step_monitor" "dummy_glasses" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_3"]
  name                                    = "dummy-glasses"
  period                                  = "EVERY_15_MINUTES"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  status                                  = "ENABLED"

  steps {
    ordinal = 0
    type    = "NAVIGATE"
    values = ["https://www.afflelou.com/"]
  }
  steps {
    ordinal = 1
    type    = "CLICK_ELEMENT"
    values  = ["/html/body/div[1]/main/div[3]/div/div[2]/div/div/div[2]/div[1]"]
  }
  steps {
    ordinal = 2
    type    = "CLICK_ELEMENT"
    values  = ["//main//a[normalize-space()='Accessoires connectés']"]
  }
  steps {
    ordinal = 3
    type    = "CLICK_ELEMENT"
    values  = ["//*[@src='https://www.afflelou.com/media/catalog/product/3/9/3965f90a9e41f86fb6e60fe6361574f8.png?width=700&height=700&canvas=700,700&optimize=high&bg-color=243,244,246&fit=bounds&format=jpeg']"]
  }
  steps {
    ordinal = 4
    type    = "HOVER_ELEMENT"
    values  = ["//*[@data-aff-tracking-event-name='GAevent']"]
  }
}

resource "newrelic_synthetics_step_monitor" "again_dummy" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_2"]
  name                                    = "again-dummy"
  period                                  = "EVERY_15_MINUTES"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  status                                  = "ENABLED"

  steps {
    ordinal = 0
    type    = "NAVIGATE"
    values = ["https://www.afflelou.com/"]
  }
  steps {
    ordinal = 1
    type    = "CLICK_ELEMENT"
    values  = ["//*[@id='ppms_cm_agree-to-all']"]
  }
  steps {
    ordinal = 2
    type    = "CLICK_ELEMENT"
    values  = ["//nav//a[normalize-space()='Audition']"]
  }
  steps {
    ordinal = 3
    type    = "CLICK_ELEMENT"
    values  = ["//main//a[normalize-space()='Accessoires connectés']"]
  }
  steps {
    ordinal = 4
    type    = "CLICK_ELEMENT"
    values  = ["//*[@title='Micro déporté']"]
  }
  steps {
    ordinal = 5
    type    = "CLICK_ELEMENT"
    values  = ["//*[@data-aff-tracking-event-name='GAevent']"]
  }
  steps {
    ordinal = 6
    type    = "CLICK_ELEMENT"
    values  = ["//*[@href='https://www.afflelou.com/audioprothesiste/bourges/afflelou-c-c-carrefour-chaussee-de-chappe-18000']"]
  }
}

resource "newrelic_synthetics_script_monitor" "nr_login" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "NR_LOGIN"
  period                                  = "EVERY_5_MINUTES"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script                                  = "var assert = require('assert');\nvar defaultTimeout = 10000;\n\n\n$browser.get('https://newrelic.com').then(function() {\n    $browser.manage().window().setSize(1920, 1080).then(function() {\n        $browser.get('https://login.newrelic.com/login?authentication_domain_id=795309ee-9c8b-411b-b966-e49c71417c75').then(function() {\n            $browser.waitForAndFindElement($driver.By.id('login_email'), defaultTimeout).then(function(el) {\n                el.sendKeys($secure.LOGIN_EMAIL).then(function() {\n                    $browser.waitForAndFindElement($driver.By.id('login_password'), defaultTimeout).then(function(el) {\n                        el.sendKeys($secure.LOGIN_PASSWORD).then(function() {\n                            $browser.waitForAndFindElement($driver.By.id('login_submit'), defaultTimeout).then(function(el) {\n                                el.click().then(function() {\n                                    $browser.get('https://one.eu.newrelic.com').then(function() {\n                                        $browser.sleep(defaultTimeout)\n                                    })\n                                })\n                            })\n                        })\n                    })\n                })\n            })\n        })\n    })\n})"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_BROWSER"

}

resource "newrelic_synthetics_script_monitor" "auto_deployment_marker_from_github" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_2"]
  name                                    = "Auto Deployment Marker from GitHub"
  period                                  = "EVERY_5_MINUTES"
  runtime_type                            = "NODE_API"
  runtime_type_version                    = "22.20.0"
  script                                  = "const assert = require('assert');\n\n/**\n * CONFIGURATION\n */\nconst GITHUB_ACC = YOUR_GITHUB_ACCOUNT_ID;\nconst DEPLOY_ACC = YOUR_DEPLOY_ACCOUNT_ID;\nconst API_KEY = 'USER_KEY'; \nconst ENTITY_GUID = 'ENTITY_GUID';\nconst NR_GRAPHQL_URL = 'https://api.eu.newrelic.com/graphql';\n\nconsole.log(`--- UI ALIGNMENT RUN ---`);\n\n// 1. Fetch GitHub PRs (Last 2 Hours)\nconst githubQuery = `SELECT title, author, pullRequestUrl FROM GitHubPullRequest WHERE merged = true AND action = 'closed' SINCE 2 hours ago`;\n\n$http.post({\n  url: NR_GRAPHQL_URL,\n  headers: { 'Api-Key': API_KEY, 'Content-Type': 'application/json' },\n  body: JSON.stringify({\n    query: `query($accId: Int!, $nrql: Nrql!) { actor { account(id: $accId) { nrql(query: $nrql) { results } } } }`,\n    variables: { accId: GITHUB_ACC, nrql: githubQuery }\n  })\n}, function(err, response, body) {\n  const parsedBody = (typeof body === 'string') ? JSON.parse(body) : body;\n  const merges = parsedBody.data.actor.account.nrql.results;\n  \n  if (!merges || merges.length === 0) {\n      console.log(\"No new GitHub PRs found.\");\n      return;\n  }\n\n  merges.forEach((merge) => {\n    checkExistingMarkers(merge);\n  });\n});\n\n/**\n * 2. Audit the Deployment Account (YOUR_ACCOUNT_ID)\n */\nfunction checkExistingMarkers(merge) {\n    const safeTitle = merge.title.replace(/'/g, \"\\\\'\");\n    \n    // Audit looks for the title in BOTH shortDescription and description\n    const auditQuery = `\n        SELECT count(*) FROM ChangeTrackingEvent, Deployment \n        WHERE (entity.guid = '$${ENTITY_GUID}' OR entityGuid = '$${ENTITY_GUID}')\n        AND (shortDescription LIKE '%$${safeTitle}%' OR description LIKE '%$${safeTitle}%' OR groupId = '$${merge.pullRequestUrl}')\n        SINCE 2 hours ago\n    `;\n    \n    $http.post({\n        url: NR_GRAPHQL_URL,\n        headers: { 'Api-Key': API_KEY, 'Content-Type': 'application/json' },\n        body: JSON.stringify({\n            query: `query($accId: Int!, $nrql: Nrql!) { actor { account(id: $accId) { nrql(query: $nrql) { results } } } }`,\n            variables: { accId: DEPLOY_ACC, nrql: auditQuery }\n        })\n    }, function(err, response, body) {\n        const parsed = (typeof body === 'string') ? JSON.parse(body) : body;\n        const count = parsed.data.actor.account.nrql.results[0].count;\n\n        if (count > 0) {\n            console.log(`[DEDUPE] Found existing marker for \"$${merge.title}\". Skipping.`);\n        } else {\n            console.log(`[ACTION] No marker found for \"$${merge.title}\". Creating...`);\n            createMarker(merge);\n        }\n    });\n}\n\n/**\n * 3. Create Unique Marker - MAPPING TITLE TO SHORT DESCRIPTION\n */\nfunction createMarker(deploy) {\n  const mutation = `\n    mutation {\n      changeTrackingCreateEvent(\n        changeTrackingEvent: {\n          categoryAndTypeData: {\n            categoryFields: { deployment: { version: \"v1.0\" } }\n            kind: { category: \"Deployment\", type: \"Basic\" }\n          }\n          user: \"$${deploy.author}\"\n          shortDescription: \"$${deploy.title}\"\n          description: \"GitHub PR: $${deploy.pullRequestUrl}\"\n          groupId: \"$${deploy.pullRequestUrl}\"\n          entitySearch: { query: \"id = '$${ENTITY_GUID}'\" }\n        }\n      ) {\n        changeTrackingEvent { changeTrackingId }\n      }\n    }\n  `;\n\n  $http.post({\n    url: NR_GRAPHQL_URL,\n    headers: { 'Api-Key': API_KEY, 'Content-Type': 'application/json' },\n    body: JSON.stringify({ query: mutation })\n  }, function(err, response, body) {\n     console.log(`[SUCCESS] Unique Marker set with Title: $${deploy.title}`);\n  });\n}"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_API"

}

resource "newrelic_synthetics_script_monitor" "test_scripted_browser_monitor" {
  account_id                              = var.account_id

  locations_public                        = ["US_EAST_1"]
  name                                    = "Test Scripted Browser Monitor"
  period                                  = "EVERY_10_MINUTES"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script                                  = "var assert = require('assert');\n$browser.get('https://example.com');"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_BROWSER"

}

resource "newrelic_synthetics_script_monitor" "test_scripted_browser_monitor_ks" {
  account_id                              = var.account_id

  locations_public                        = ["US_EAST_1"]
  name                                    = "Test Scripted Browser Monitor-KS"
  period                                  = "EVERY_10_MINUTES"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script                                  = "var assert = require('assert');\n$browser.get('https://example.com');"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_BROWSER"

}

resource "newrelic_synthetics_script_monitor" "scheduled_dashboards" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "Scheduled dashboards"
  period                                  = "EVERY_DAY"
  runtime_type                            = "NODE_API"
  runtime_type_version                    = "22.20.0"
  script                                  = "/**\n * New Relic Synthetic Monitor: Multi-App Dashboard Email with Dynamic Variables\n * \n * This script:\n * 1. Queries New Relic to get all unique appName values\n * 2. Generates a dashboard permalink for each app\n * 3. Sends an email with all dashboard links via Mailgun\n */\n\nconst assert = require('assert');\nconst https = require('https');\n\n// ============================================================================\n// CONFIGURATION - Update these values\n// ============================================================================\n\nconst CONFIG = {\n  // New Relic Configuration\n  accountId: YOUR_ACCOUNT_ID,\n  dashboardGuid: 'NzY5NzkzMXxWSVp8REFTSEJPQVJEfGRhOjI3MTczODU',\n  region: 'EU', // 'US' or 'EU'\n  \n  // Email Configuration\n  emailTo: 'your-email@example.com',\n  emailFrom: 'Dashboard Reports <noreply@YOUR_MAILGUN_DOMAIN>',\n  emailSubject: 'Daily Dashboard Report - All Applications',\n  \n  // Template Variable Configuration\n  templateVariableName: 'appName', // The exact variable name in your dashboard\n  \n  // NRQL Query to fetch variable values\n  nrqlQuery: 'SELECT uniques(appName) FROM Transaction SINCE 1 day ago'\n};\n\n// ============================================================================\n// HELPER FUNCTIONS\n// ============================================================================\n\n/**\n * Make HTTPS request (promisified)\n */\nfunction makeRequest(options, postData = null) {\n  return new Promise((resolve, reject) => {\n    const req = https.request(options, (res) => {\n      let data = '';\n      res.on('data', (chunk) => { data += chunk; });\n      res.on('end', () => {\n        if (res.statusCode >= 200 && res.statusCode < 300) {\n          resolve({ statusCode: res.statusCode, body: data });\n        } else {\n          reject(new Error(`Request failed with status $${res.statusCode}: $${data}`));\n        }\n      });\n    });\n    \n    req.on('error', reject);\n    if (postData) req.write(postData);\n    req.end();\n  });\n}\n\n/**\n * Execute NRQL query via NerdGraph\n */\nasync function executeNrqlQuery(accountId, nrqlQuery, userApiKey) {\n  console.log(`Executing NRQL query: $${nrqlQuery}`);\n  \n  const query = `\n    query($accountId: Int!, $nrql: Nrql!) {\n      actor {\n        account(id: $accountId) {\n          nrql(query: $nrql) {\n            results\n          }\n        }\n      }\n    }\n  `;\n  \n  const variables = {\n    accountId: accountId,\n    nrql: nrqlQuery\n  };\n  \n  const options = {\n    hostname: 'api.eu.newrelic.com',\n    port: 443,\n    path: '/graphql',\n    method: 'POST',\n    headers: {\n      'Content-Type': 'application/json',\n      'API-Key': userApiKey\n    }\n  };\n  \n  const response = await makeRequest(options, JSON.stringify({ query, variables }));\n  const result = JSON.parse(response.body);\n  \n  if (result.errors) {\n    throw new Error(`NerdGraph query failed: $${JSON.stringify(result.errors)}`);\n  }\n  \n  return result.data.actor.account.nrql.results;\n}\n\n/**\n * Generate dashboard permalink with template variable\n */\nfunction generateDashboardUrl(dashboardGuid, region, templateVariableName, templateValue) {\n  const baseUrl = region === 'EU' \n    ? 'https://one.eu.newrelic.com' \n    : 'https://one.newrelic.com';\n  \n  // URL encode the template variable name and value\n  const encodedVarName = encodeURIComponent(templateVariableName);\n  const encodedVarValue = encodeURIComponent(templateValue);\n  \n  return `$${baseUrl}/redirect/entity/$${dashboardGuid}?var-$${encodedVarName}=$${encodedVarValue}`;\n}\n\n/**\n * Send email via Mailgun\n */\nasync function sendEmail(mailgunDomain, mailgunApiKey, from, to, subject, htmlBody) {\n  console.log(`Sending email to: $${to}`);\n  \n  const formData = new URLSearchParams({\n    from: from,\n    to: to,\n    subject: subject,\n    html: htmlBody\n  });\n  \n  const auth = Buffer.from(`api:$${mailgunApiKey}`).toString('base64');\n  \n  const options = {\n    hostname: 'api.mailgun.net',\n    port: 443,\n    path: `/v3/$${mailgunDomain}/messages`,\n    method: 'POST',\n    headers: {\n      'Authorization': `Basic $${auth}`,\n      'Content-Type': 'application/x-www-form-urlencoded',\n      'Content-Length': Buffer.byteLength(formData.toString())\n    }\n  };\n  \n  const response = await makeRequest(options, formData.toString());\n  console.log('Email sent successfully');\n  return response;\n}\n\n/**\n * Generate HTML email body with all dashboard links\n */\nfunction generateEmailHtml(dashboardLinks) {\n  const linkRows = dashboardLinks.map(link => `\n    <tr>\n      <td style=\"padding: 12px; border-bottom: 1px solid #e0e0e0;\">\n        <strong>$${link.appName}</strong>\n      </td>\n      <td style=\"padding: 12px; border-bottom: 1px solid #e0e0e0;\">\n        <a href=\"$${link.url}\" \n           style=\"color: #007bff; text-decoration: none; font-weight: 500;\">\n          View Dashboard →\n        </a>\n      </td>\n    </tr>\n  `).join('');\n  \n  return `\n    <!DOCTYPE html>\n    <html>\n    <head>\n      <meta charset=\"UTF-8\">\n      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    </head>\n    <body style=\"font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px;\">\n      <div style=\"background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 8px 8px 0 0; text-align: center;\">\n        <h1 style=\"color: white; margin: 0; font-size: 28px;\">📊 Dashboard Report</h1>\n        <p style=\"color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 16px;\">\n          Application Performance Overview\n        </p>\n      </div>\n      \n      <div style=\"background: #f8f9fa; padding: 30px; border-radius: 0 0 8px 8px;\">\n        <p style=\"font-size: 16px; margin-bottom: 20px;\">\n          Hello! Here are your dashboard links for all monitored applications:\n        </p>\n        \n        <table style=\"width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);\">\n          <thead>\n            <tr style=\"background: #f1f3f5;\">\n              <th style=\"padding: 15px; text-align: left; font-weight: 600; color: #495057; border-bottom: 2px solid #dee2e6;\">\n                Application Name\n              </th>\n              <th style=\"padding: 15px; text-align: left; font-weight: 600; color: #495057; border-bottom: 2px solid #dee2e6;\">\n                Dashboard Link\n              </th>\n            </tr>\n          </thead>\n          <tbody>\n            $${linkRows}\n          </tbody>\n        </table>\n        \n        <div style=\"margin-top: 30px; padding: 20px; background: #e7f3ff; border-left: 4px solid #007bff; border-radius: 4px;\">\n          <p style=\"margin: 0; font-size: 14px; color: #004085;\">\n            <strong>📌 Note:</strong> These links will open the dashboard pre-filtered for each specific application.\n            You must be logged into New Relic to view the dashboards.\n          </p>\n        </div>\n        \n        <div style=\"margin-top: 30px; padding-top: 20px; border-top: 1px solid #dee2e6; text-align: center; color: #6c757d; font-size: 14px;\">\n          <p style=\"margin: 0;\">\n            Generated by New Relic Synthetic Monitor<br>\n            Report Date: $${new Date().toLocaleString('en-US', { timeZone: 'UTC' })} UTC\n          </p>\n        </div>\n      </div>\n    </body>\n    </html>\n  `;\n}\n\n// ============================================================================\n// MAIN EXECUTION\n// ============================================================================\n\n(async function() {\n  console.log('=== Starting Multi-App Dashboard Email Process ===');\n  \n  try {\n    // Get secure credentials\n    const userApiKey = $secure.NEW_RELIC_USER_KEY;\n    const mailgunDomain = $secure.MAILGUN_DOMAIN;\n    const mailgunApiKey = $secure.MAILGUN_API_KEY;\n    \n    // Validate credentials\n    assert(userApiKey, 'NEW_RELIC_USER_KEY is required');\n    assert(mailgunDomain, 'MAILGUN_DOMAIN is required');\n    assert(mailgunApiKey, 'MAILGUN_API_KEY is required');\n    \n    console.log('✓ Credentials validated');\n    \n    // Step 1: Execute NRQL query to get all app names\n    console.log('\\n--- Step 1: Fetching app names from NRQL query ---');\n    const queryResults = await executeNrqlQuery(\n      CONFIG.accountId,\n      CONFIG.nrqlQuery,\n      userApiKey\n    );\n    \n    console.log(`Query returned $${queryResults.length} results`);\n    \n    // Extract unique app names from results\n    // The query returns results like: [{ \"uniques.appName\": [\"app1\", \"app2\", ...] }]\n    let appNames = [];\n    if (queryResults.length > 0 && queryResults[0][`uniques.$${CONFIG.templateVariableName}`]) {\n      appNames = queryResults[0][`uniques.$${CONFIG.templateVariableName}`];\n    }\n    \n    console.log(`Found $${appNames.length} unique app names:`, appNames);\n    \n    if (appNames.length === 0) {\n      throw new Error('No app names found from NRQL query');\n    }\n    \n    // Step 2: Generate dashboard URLs for each app\n    console.log('\\n--- Step 2: Generating dashboard URLs ---');\n    const dashboardLinks = appNames.map(appName => {\n      const url = generateDashboardUrl(\n        CONFIG.dashboardGuid,\n        CONFIG.region,\n        CONFIG.templateVariableName,\n        appName\n      );\n      console.log(`  $${appName}: $${url}`);\n      return { appName, url };\n    });\n    \n    // Step 3: Generate email HTML\n    console.log('\\n--- Step 3: Generating email content ---');\n    const emailHtml = generateEmailHtml(dashboardLinks);\n    \n    // Step 4: Send email\n    console.log('\\n--- Step 4: Sending email ---');\n    await sendEmail(\n      mailgunDomain,\n      mailgunApiKey,\n      CONFIG.emailFrom,\n      CONFIG.emailTo,\n      CONFIG.emailSubject,\n      emailHtml\n    );\n    \n    console.log('\\n=== Process completed successfully ===');\n    console.log(`✓ Generated $${dashboardLinks.length} dashboard links`);\n    console.log(`✓ Email sent to $${CONFIG.emailTo}`);\n    \n  } catch (error) {\n    console.error('\\n=== Process failed ===');\n    console.error('Error:', error.message);\n    console.error('Stack:', error.stack);\n    throw error;\n  }\n})();"
  script_language                         = "JAVASCRIPT"
  status                                  = "DISABLED"
  type                                    = "SCRIPT_API"

}

resource "newrelic_synthetics_script_monitor" "test_scripted_browser_monitor_ks2" {
  account_id                              = var.account_id

  locations_public                        = ["US_EAST_1"]
  name                                    = "Test Scripted Browser Monitor-KS2"
  period                                  = "EVERY_10_MINUTES"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script                                  = "var assert = require('assert');\n$browser.get('https://example.com');"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_BROWSER"

}

resource "newrelic_synthetics_script_monitor" "outdated_tdv_checker" {
  account_id                              = var.account_id

  locations_public                        = ["EU_CENTRAL_1"]
  name                                    = "Outdated TDV Checker"
  period                                  = "EVERY_30_MINUTES"
  runtime_type                            = "NODE_API"
  runtime_type_version                    = "22.20.0"
  script                                  = "const assert = require('assert');\n\n// 1. MOCK DATA\n// We simulate the raw data you would normally fetch from your API/Database.\n// The keys match what your map() function looks for (brand_code, country_code, etc.)\nconst filtered_results = [\n    {\n        brand_code: \"LB\",\n        country_code: \"WORLD\",\n        product_data_key: \"DCC-WORLD-NG\",\n        hostupdatetimestamp: 1773260242219\n    },\n    {\n        brand_code: \"LB\",\n        country_code: \"WORLD\",\n        product_data_key: \"A-PRESERIES\",\n        hostupdatetimestamp: 1773260242219\n    }\n];\n\n// 2. YOUR PROCESSING LOGIC\nif (filtered_results.length > 0) {\n    const result = filtered_results.map(item => {\n        const date_object = new Date(item.hostupdatetimestamp);\n        const core_host_update_timestamp = date_object.toLocaleString('de-DE', {\n            day: '2-digit', \n            month: '2-digit', \n            year: 'numeric', \n            hour: '2-digit', \n            minute: '2-digit', \n            second: '2-digit'\n        });\n\n        return {\n            \"brand\": item.brand_code,\n            \"country\": item.country_code,\n            \"pdk\": item.product_data_key,\n            \"core_host_update_timestamp\": item.hostupdatetimestamp,\n            \"core_host_update_date\": core_host_update_timestamp\n        };\n    });\n\n    const output = JSON.stringify(result);\n    console.log(\"Payload being sent to Insights:\", output);\n    \n    // Push custom attributes to the SyntheticCheck event in NRDB\n    $util.insights.set(\"count\", filtered_results.length);\n    $util.insights.set(\"content\", output);\n    \n    // Intentionally fail the script to trigger your Alert and Workflow Email\n    assert.fail(`Outdated TDV's detected: $${filtered_results.length}`);\n    \n} else {\n    $util.insights.set(\"count\", 0);\n    $util.insights.set(\"content\", JSON.stringify([]));\n    console.log(\"No outdated TDVs found. Monitor passed.\");\n}\n"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_API"

}

resource "newrelic_synthetics_monitor" "test_emanuele" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "Test Emanuele"
  period                                  = "EVERY_10_MINUTES"

  status                                  = "ENABLED"

  type                                    = "SIMPLE"
  uri                                     = "https://www.newrelic.com"

  verify_ssl                              = false
}

resource "newrelic_synthetics_script_monitor" "nta_api" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "NTA API"
  period                                  = "EVERY_MINUTE"
  runtime_type                            = "NODE_API"
  runtime_type_version                    = "22.20.0"
  script                                  = "/**\n * New Relic Scripted API Monitor\n * Join NTA Data & Send via Event API (POST)\n */\n\nconst assert = require('assert');\n\n// --- CONFIGURATION ---\nconst NTA_API_KEY = $secure.NTA_API_KEY; \nconst NR_LICENSE_KEY = $secure.NR_LICENSE_KEY; // Your New Relic Ingest License Key\nconst NR_ACCOUNT_ID = $env.ACCOUNT_ID; // Replace with your Account ID\n\nconst NTA_HEADERS = { 'x-api-key': NTA_API_KEY, 'Accept': 'application/json' };\n\n// Endpoints\nconst TRIP_URL = 'https://api.nationaltransport.ie/gtfsr/v2/gtfsr?format=json';\nconst VEHICLE_URL = 'https://api.nationaltransport.ie/gtfsr/v2/Vehicles?format=json';\nconst NR_EVENT_API_URL = `https://insights-collector.eu01.nr-data.net/v1/accounts/$${NR_ACCOUNT_ID}/events`;\n\nasync function runCheck() {\n    try {\n        // 1. Fetch both NTA datasets in parallel\n        console.log('Fetching NTA data...');\n        const [tripRes, vehRes] = await Promise.all([\n            $http.get({ url: TRIP_URL, headers: NTA_HEADERS, responseType: 'json' }),\n            $http.get({ url: VEHICLE_URL, headers: NTA_HEADERS, responseType: 'json' })\n        ]);\n\n        assert.equal(tripRes.statusCode, 200, 'NTA Trip API failed');\n        assert.equal(vehRes.statusCode, 200, 'NTA Vehicles API failed');\n\n        const tripUpdates = tripRes.body.entity || [];\n        const vehiclePositions = vehRes.body.entity || [];\n\n        // 2. Map Vehicle Positions by Vehicle ID for lookup\n        const vehicleMap = new Map();\n        vehiclePositions.forEach(ent => {\n            if (ent.vehicle && ent.vehicle.vehicle) {\n                vehicleMap.set(ent.vehicle.vehicle.id, ent.vehicle);\n            }\n        });\n\n        // 3. Join and Flatten (Limiting to a sample of 20 for this example)\n        const payload = tripUpdates\n            .filter(ent => ent.trip_update && ent.trip_update.vehicle) \n            .map(ent => {\n                const trip = ent.trip_update;\n                const vId = trip.vehicle.id;\n                const vData = vehicleMap.get(vId);\n\n                return {\n                    // \"eventType\" is mandatory for the Event API\n                    eventType: 'NtaTransitEvent', \n                    vehicle_id: vId,\n                    trip_id: trip.trip.trip_id,\n                    route_id: trip.trip.route_id,\n                    delay_seconds: trip.stop_time_update?.[0]?.arrival?.delay || 0,\n                    latitude: vData?.position?.latitude || null,\n                    longitude: vData?.position?.longitude || null,\n                    gtfs_timestamp: vData?.timestamp || Math.floor(Date.now() / 1000),\n                    monitor_name: 'NTA_Scripted_Check'\n                };\n            });\n\n        console.log(`Prepared $${payload.length} events. Sending to New Relic Event API...`);\n\n        // 4. POST to New Relic Event API\n        const nrOptions = {\n            url: NR_EVENT_API_URL,\n            headers: {\n                'Api-Key': NR_LICENSE_KEY,\n                'Content-Type': 'application/json'\n            },\n            json: payload // 'got' automatically stringifies arrays passed to 'json'\n        };\n\n        const nrResponse = await $http.post(nrOptions);\n\n        // 5. Final Validation\n        if (nrResponse.statusCode === 200 || nrResponse.statusCode === 202) {\n            console.log('Successfully ingested events into New Relic.');\n            console.log('Response:', nrResponse.body);\n        } else {\n            console.error('Failed to send to Event API:', nrResponse.body);\n            assert.fail(`Event API returned status $${nrResponse.statusCode}`);\n        }\n\n    } catch (err) {\n        assert.fail('Script failed: ' + err.message);\n    }\n}\n\nrunCheck();"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_API"

}

resource "newrelic_synthetics_monitor" "sandbox_account___james_test" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "Sandbox Account - James Test"
  period                                  = "EVERY_MINUTE"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"

  type                                    = "BROWSER"
  uri                                     = "https://newrelic.com"

  verify_ssl                              = false
}

resource "newrelic_synthetics_monitor" "test" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "test"
  period                                  = "EVERY_DAY"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"

  type                                    = "BROWSER"
  uri                                     = "https://example.com"

  verify_ssl                              = false
}

resource "newrelic_synthetics_script_monitor" "microsoft_health" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "Microsoft health"
  period                                  = "EVERY_HOUR"
  runtime_type                            = "CHROME_BROWSER"
  runtime_type_version                    = "LATEST"
  script                                  = "/**\n * Feel free to explore, or check out the full documentation\n * https://docs.newrelic.com/docs/synthetics/new-relic-synthetics/scripting-monitors/writing-api-tests\n * for details.\n */\n\nconst assert = require('assert');\nconst got = require('got');\n\n/**\n * VARIABLE DEFINITIONS\n */\nconst NEW_RELIC_ACCOUNT_ID = $secure.NEW_RELIC_ACCOUNT_ID;\nconst NEW_RELIC_INSIGHTS_INSERT_KEY = $secure.NEW_RELIC_INSIGHTS_INSERT_KEY;\nconst NEW_RELIC_EVENT_TYPE = 'M365ServiceOverview';\nconst NEW_RELIC_REGION = $secure.NEW_RELIC_REGION || 'EU';\nconst MSFT_TENANT_ID = $secure.MSFT_TENANT_ID;\nconst MSFT_CLIENT_ID = $secure.MSFT_CLIENT_ID;\nconst MSFT_CLIENT_SECRET = $secure.MSFT_CLIENT_SECRET;\n\n/**\n * Function to post events to the New Relic Events API\n * @param {*} body \n * @returns {Promise<got.Response>}\n */\nasync function insertInsightsEvent(body) {\n    const insightsCollectorUrl = NEW_RELIC_REGION === 'EU'\n        ? 'https://insights-collector.eu01.nr-data.net'\n        : 'https://insights-collector.newrelic.com';\n    const URL = `$${insightsCollectorUrl}/v1/accounts/$${NEW_RELIC_ACCOUNT_ID}/events`;\n    const options = {\n        body: body,\n        headers: {\n            'X-Insert-Key': NEW_RELIC_INSIGHTS_INSERT_KEY,\n            'Content-Type': 'application/json'\n        },\n        throwHttpErrors: false\n    };\n    return got.post(URL, options);\n}\n\n/**\n * Function to record data in NRDB.\n * @param events\n * @returns {Promise<void>}\n */\nasync function recordData(events) {\n    //console.log(events);\n    const body = JSON.stringify(events, null, 2);\n    const insightsResponse = await insertInsightsEvent(body);\n    if (insightsResponse.statusCode !== 200) {\n        console.log(`insertInsightsEvent() non-200 return code: $${insightsResponse.statusCode}, body: $${insightsResponse.body}`);\n    } else {\n        console.log('Script executed successfully');\n    }\n}\n\nasync function main() {\n    // MSFT Auth request to get token\n    const urlAuth = `https://login.microsoftonline.com/$${MSFT_TENANT_ID}/oauth2/v2.0/token`;\n    const authOptions = {\n        form: {\n            client_id: MSFT_CLIENT_ID,\n            client_secret: MSFT_CLIENT_SECRET,\n            scope: 'https://graph.microsoft.com/.default',\n            grant_type: 'client_credentials'\n        },\n        responseType: 'json'\n    };\n\n    console.log(\"Authenticating with Microsoft...\");\n    const authResponse = await got.post(urlAuth, authOptions);\n    assert.strictEqual(authResponse.statusCode, 200, 'Expected a 200 OK response from auth');\n    const accessToken = authResponse.body.access_token;\n    console.log(\"Authentication successful.\");\n\n    // MSFT Graph API request for service health\n    const graphUrl = 'https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/healthOverviews';\n    const graphOptions = {\n        headers: {\n            'Authorization': `Bearer $${accessToken}`\n        },\n        responseType: 'json'\n    };\n\n    console.log(\"Fetching service health from Microsoft Graph API...\");\n    const graphResponse = await got.get(graphUrl, graphOptions);\n    assert.strictEqual(graphResponse.statusCode, 200, 'Expected a 200 OK response from Graph API');\n    console.log(\"Service health fetched successfully.\");\n    \n    const jsonResponseValue = graphResponse.body.value;\n\n    jsonResponseValue.forEach(item => {\n        item.eventType = NEW_RELIC_EVENT_TYPE;\n        item.location = $env.LOCATION;\n        if (item.status === \"serviceDegradation\") {\n            item.statusVal = 1;\n        } else if (item.status === \"serviceOperational\") {\n            item.statusVal = 0;\n        }\n    });\n\n    console.log(\"Recording data in New Relic...\");\n    await recordData(jsonResponseValue);\n    console.log(\"Data recorded.\");\n}\n\nmain().catch(err => {\n    console.error(\"Script failed.\", err);\n    // Use a top-level assert.fail to ensure the synthetic monitor fails.\n    assert.fail(`Script failed: $${err.message}`);\n});\n"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_BROWSER"

}

resource "newrelic_synthetics_script_monitor" "dashboard_lookup" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_2"]
  name                                    = "dashboard Lookup"
  period                                  = "EVERY_15_MINUTES"
  runtime_type                            = "NODE_API"
  runtime_type_version                    = "16.10"
  script                                  = "const got = require('got');\n\n// --- Configuration ---\nconst CONFIG = {\n  // 1. INSERT YOUR ACCOUNT ID\n  accountId: 'YOUR_ACCOUNT_ID',\n  \n  // 2. INSERT YOUR USER API KEY (Must start with NRAK-...)\n  apiKey: $secure.NR_API_KEY, \n  \n  // 3. The specific name you requested\n  tableName: 'Dashboard_Names',\n  \n  // 4. Region: Set to 'EU' if your account is in Europe, otherwise 'US'\n  region: 'EU' \n};\n\n// --- Endpoints ---\n// Base URL for Lookups (used for creating new tables)\nconst LOOKUP_BASE = CONFIG.region === 'EU'\n  ? `https://nrql-lookup.service.eu.newrelic.com/v1/accounts/$${CONFIG.accountId}/Dashboard_Names`\n  : `https://nrql-lookup.service.newrelic.com/v1/accounts/$${CONFIG.accountId}/Dashboard_Names`;\n\nconst GRAPHQL_ENDPOINT = CONFIG.region === 'EU' \n  ? 'https://api.eu.newrelic.com/graphql' \n  : 'https://api.newrelic.com/graphql';\n\n/**\n * Step 1: Fetch all dashboards from NerdGraph\n * Handles pagination if you have > 200 dashboards\n */\nasync function fetchAllDashboards() {\n  let allDashboards = [];\n  let cursor = null;\n  let hasMore = true;\n\n  const query = `\n    query($cursor: String) {\n      actor {\n        entitySearch(query: \"type = 'DASHBOARD'\") {\n          results(cursor: $cursor) {\n            entities {\n              name\n              guid\n            }\n            nextCursor\n          }\n        }\n      }\n    }\n  `;\n\n  console.log('Fetching dashboards from NerdGraph...');\n\n  while (hasMore) {\n    const response = await got.post(GRAPHQL_ENDPOINT, {\n      headers: { 'API-Key': CONFIG.apiKey },\n      json: { query, variables: { cursor } },\n      responseType: 'json'\n    });\n\n    const resultData = response.body.data.actor.entitySearch.results;\n    \n    if (resultData.entities && resultData.entities.length > 0) {\n      allDashboards.push(...resultData.entities);\n    }\n\n    if (resultData.nextCursor) {\n      cursor = resultData.nextCursor;\n    } else {\n      hasMore = false;\n    }\n  }\n\n  console.log(`Found $${allDashboards.length} dashboards.`);\n  return allDashboards;\n}\n\n/**\n * Step 2: Create or Update the Lookup Table\n * Logic: Try to Update (PUT). If 404, Create (POST).\n */\nasync function upsertLookupTable(dashboards) {\n  if (dashboards.length === 0) {\n    console.log('No dashboards found. Skipping update.');\n    return;\n  }\n\n  // Define the data structure\n  const tableData = {\n    headers: ['dashboardName', 'guid'],\n    rows: dashboards.map(d => [d.name, d.guid])\n  };\n\n  // headers for the HTTP request\n  const httpHeaders = { \n    'Api-Key': CONFIG.apiKey,\n    'Content-Type': 'application/json'\n  };\n\n  console.log(`Checking if table \"$${CONFIG.tableName}\" exists by attempting an UPDATE (PUT)...`);\n\n  try {\n    // --- STRATEGY: Optimistic Update ---\n    // 1. Try to PUT to the specific table URL: .../lookups/Dashboard_Names\n    const putUrl = `$${LOOKUP_BASE}/$${CONFIG.tableName}`;\n    \n    // Payload for PUT: Only needs the table data\n    const putPayload = {\n      table: tableData\n    };\n\n    await got.put(putUrl, {\n      headers: httpHeaders,\n      json: putPayload\n    });\n\n    console.log(`Success: Table \"$${CONFIG.tableName}\" existed and was updated.`);\n\n  } catch (error) {\n    // 2. If 404, the table does not exist. We must CREATE (POST) it.\n    if (error.response && error.response.statusCode === 404) {\n      console.log('Result: Table not found (404). Switching to CREATE (POST) mode...');\n      \n      // Endpoint for POST: The base lookups URL\n      // Payload for POST: Needs \"name\" inside the body\n      const postPayload = {\n        name: CONFIG.tableName,\n        description: \"All current Dashboard names\",\n        table: tableData\n      };\n\n      try {\n        await got.post(LOOKUP_BASE, {\n          headers: httpHeaders,\n          json: postPayload\n        });\n        console.log(`Success: Table \"$${CONFIG.tableName}\" created.`);\n      } catch (createErr) {\n        console.error('Error creating table:', createErr.response ? createErr.response.body : createErr.message);\n        throw createErr;\n      }\n\n    } else {\n      // If error was NOT a 404 (e.g. 401 Auth error, 500 Server error), fail the script\n      console.error('Error updating table:', error.response ? error.response.body : error.message);\n      throw error;\n    }\n  }\n}\n\n// --- Main Execution ---\n(async function() {\n  try {\n    const dashboards = await fetchAllDashboards();\n    await upsertLookupTable(dashboards);\n  } catch (err) {\n    console.error('Script Failed:', err);\n    throw err; // Ensure Synthetics marks the check as FAILED\n  }\n})();"
  script_language                         = "JAVASCRIPT"
  status                                  = "DISABLED"
  type                                    = "SCRIPT_API"

}

resource "newrelic_synthetics_script_monitor" "scheduled_dashboard_report" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "Scheduled dashboard report"
  period                                  = "EVERY_15_MINUTES"
  runtime_type                            = "NODE_API"
  runtime_type_version                    = "22.20.0"
  script                                  = "/**\n * New Relic Synthetic Monitor - Scheduled SMTP Email Sender\n * Runtime: Node.js 16.10 or later\n * Monitor Type: Scripted API\n * \n * Secure Variables Required (Configure in Monitor Settings):\n * - SMTP_HOST: Your SMTP server (e.g., smtp.gmail.com)\n * - SMTP_PORT: SMTP port (e.g., 587 for TLS, 465 for SSL)\n * - SMTP_USER: Your email username\n * - SMTP_PASSWORD: Your email password or app-specific password\n * - SMTP_FROM: Sender email address\n */\n\nconst assert = require('assert');\n\n// Email configuration\nconst emailConfig = {\n  host: $secure.SMTP_HOST || 'smtp.gmail.com',\n  port: parseInt($secure.SMTP_PORT || '587'),\n  secure: $secure.SMTP_PORT === '465', // true for 465, false for other ports\n  auth: {\n    user: $secure.SMTP_USER,\n    pass: $secure.SMTP_PASSWORD\n  },\n  from: $secure.SMTP_FROM || $secure.SMTP_USER,\n  to: 'your-email@example.com'\n};\n\n// Email content\nconst emailSubject = `New Relic Scheduled Report - $${new Date().toLocaleDateString()}`;\nconst emailBody = `\nHello,\n\nThis is your scheduled report from New Relic Synthetic Monitoring.\n\nReport Details:\n- Timestamp: $${new Date().toISOString()}\n- Monitor: Scheduled SMTP Email Monitor\n- Account ID: YOUR_ACCOUNT_ID\n\nThis monitor is running successfully and sending emails on schedule.\n\nBest regards,\nNew Relic Synthetic Monitoring\n`;\n\n// Nodemailer-compatible SMTP function using $http\nasync function sendEmailViaSMTP() {\n  console.log('Starting SMTP email send process...');\n  \n  // Validate required credentials\n  assert($secure.SMTP_USER, 'SMTP_USER secure credential is required');\n  assert($secure.SMTP_PASSWORD, 'SMTP_PASSWORD secure credential is required');\n  \n  console.log(`SMTP Configuration:\n    Host: $${emailConfig.host}\n    Port: $${emailConfig.port}\n    User: $${emailConfig.auth.user}\n    From: $${emailConfig.from}\n    To: $${emailConfig.to}\n  `);\n\n  // For Gmail and most SMTP servers, we'll use a third-party API service\n  // since direct SMTP from Synthetics can be challenging\n  \n  // Option 1: Using SendGrid API (Recommended for Synthetics)\n  if ($secure.SENDGRID_API_KEY) {\n    return await sendViaSendGrid();\n  }\n  \n  // Option 2: Using Mailgun API\n  if ($secure.MAILGUN_API_KEY && $secure.MAILGUN_DOMAIN) {\n    return await sendViaMailgun();\n  }\n  \n  // Option 3: Using a webhook/relay service\n  if ($secure.EMAIL_WEBHOOK_URL) {\n    return await sendViaWebhook();\n  }\n  \n  throw new Error('No valid email service configured. Please set up SendGrid, Mailgun, or Webhook credentials.');\n}\n\n// SendGrid API implementation (Recommended)\nasync function sendViaSendGrid() {\n  console.log('Sending email via SendGrid API...');\n  \n  const options = {\n    url: 'https://api.sendgrid.com/v3/mail/send',\n    headers: {\n      'Authorization': `Bearer $${$secure.SENDGRID_API_KEY}`,\n      'Content-Type': 'application/json'\n    },\n    body: JSON.stringify({\n      personalizations: [{\n        to: [{ email: emailConfig.to }],\n        subject: emailSubject\n      }],\n      from: { \n        email: emailConfig.from,\n        name: 'New Relic Synthetic Monitor'\n      },\n      content: [{\n        type: 'text/plain',\n        value: emailBody\n      }]\n    })\n  };\n\n  const response = await $http.post(options);\n  \n  console.log(`SendGrid Response Status: $${response.statusCode}`);\n  assert(response.statusCode === 202, `SendGrid API failed with status $${response.statusCode}`);\n  \n  console.log('✓ Email sent successfully via SendGrid');\n  return response;\n}\n\n// Mailgun API implementation\nasync function sendViaMailgun() {\n  console.log('Sending email via Mailgun API...');\n  \n  const auth = Buffer.from(`api:$${$secure.MAILGUN_API_KEY}`).toString('base64');\n  \n  const formData = new URLSearchParams({\n    from: emailConfig.from,\n    to: emailConfig.to,\n    subject: emailSubject,\n    text: emailBody\n  });\n\n  const options = {\n    url: `https://api.mailgun.net/v3/$${$secure.MAILGUN_DOMAIN}/messages`,\n    headers: {\n      'Authorization': `Basic $${auth}`,\n      'Content-Type': 'application/x-www-form-urlencoded'\n    },\n    body: formData.toString()\n  };\n\n  const response = await $http.post(options);\n  \n  console.log(`Mailgun Response Status: $${response.statusCode}`);\n  assert(response.statusCode === 200, `Mailgun API failed with status $${response.statusCode}`);\n  \n  console.log('✓ Email sent successfully via Mailgun');\n  return response;\n}\n\n// Webhook implementation (for custom email relay)\nasync function sendViaWebhook() {\n  console.log('Sending email via Webhook...');\n  \n  const options = {\n    url: $secure.EMAIL_WEBHOOK_URL,\n    headers: {\n      'Content-Type': 'application/json',\n      'Authorization': $secure.WEBHOOK_AUTH_TOKEN || ''\n    },\n    body: JSON.stringify({\n      to: emailConfig.to,\n      from: emailConfig.from,\n      subject: emailSubject,\n      body: emailBody,\n      timestamp: new Date().toISOString()\n    })\n  };\n\n  const response = await $http.post(options);\n  \n  console.log(`Webhook Response Status: $${response.statusCode}`);\n  assert(response.statusCode &gt;= 200 && response.statusCode &lt; 300, \n    `Webhook failed with status $${response.statusCode}`);\n  \n  console.log('✓ Email sent successfully via Webhook');\n  return response;\n}\n\n// Main execution\n(async function() {\n  try {\n    console.log('=== New Relic Synthetic Monitor - SMTP Email Sender ===');\n    console.log(`Execution Time: $${new Date().toISOString()}`);\n    \n    await sendEmailViaSMTP();\n    \n    console.log('=== Monitor Execution Completed Successfully ===');\n  } catch (error) {\n    console.error('Monitor execution failed:', error.message);\n    console.error('Stack trace:', error.stack);\n    throw error; // This will mark the monitor as failed\n  }\n})();"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_API"

}

resource "newrelic_synthetics_script_monitor" "irish_rail_live_train_tracker" {
  account_id                              = var.account_id

  locations_public                        = ["EU_WEST_1"]
  name                                    = "Irish Rail Live Train Tracker"
  period                                  = "EVERY_MINUTE"
  runtime_type                            = "NODE_API"
  runtime_type_version                    = "22.20.0"
  script                                  = "/**\n * Irish Rail Realtime XML to New Relic Custom Events\n * Monitor Type: Scripted API\n * Runtime: Node.js 16+\n */\n\nconst xml2js = require('xml2js');\nconst assert = require('assert');\n\n// --- CONFIGURATION ---\nconst NR_ACCOUNT_ID = 'YOUR_ACCOUNT_ID'; // Replace with your Account ID\nconst NR_INSERT_KEY = $secure.NR_LICENSE_KEY; // Replace with your Ingest License Key\nconst IRISH_RAIL_URL = 'https://api.irishrail.ie/realtime/realtime.asmx/getCurrentTrainsXML';\nconst NR_EVENT_API_URL = `https://insights-collector.eu01.nr-data.net/v1/accounts/$${NR_ACCOUNT_ID}/events`;\n\nasync function runMonitor() {\n    console.log('Fetching Irish Rail data...');\n\n    // 1. Fetch XML Data from Irish Rail\n    const response = await $http.get(IRISH_RAIL_URL);\n    \n    if (response.statusCode !== 200) {\n        throw new Error(`Failed to fetch Irish Rail data: Status $${response.statusCode}`);\n    }\n\n    // 2. Parse XML to JSON\n    const parser = new xml2js.Parser({ explicitArray: false });\n    const result = await parser.parseStringPromise(response.body);\n\n    // Verify we have train data\n    if (!result || !result.ArrayOfObjTrainPositions || !result.ArrayOfObjTrainPositions.objTrainPositions) {\n        console.log('No train data found in feed.');\n        return;\n    }\n\n    // Ensure we handle both a single train (object) and multiple trains (array)\n    let trains = result.ArrayOfObjTrainPositions.objTrainPositions;\n    if (!Array.isArray(trains)) {\n        trains = [trains];\n    }\n\n    console.log(`Found $${trains.length} trains. Sending to New Relic...`);\n\n    // 3. Prepare data for New Relic Event API\n    // The Event API accepts an array of objects. We map the XML fields to our event.\n    const customEvents = trains.map(train => {\n        return {\n            eventType: 'LiveTrain',\n            countryCode: 'IE',\n            city: 'Dublin',\n            regionCode: 'L',\n            ...train, // This spreads all Irish Rail fields into the event (TrainCode, Status, etc.)\n            // Optional: Convert specific strings to numbers for better dashboarding\n            TrainLatitude: parseFloat(train.TrainLatitude),\n            TrainLongitude: parseFloat(train.TrainLongitude),\n            PublicMessage: train.PublicMessage ? train.PublicMessage.replace(/\\\\n/g, ' ') : ''\n        };\n    });\n\n    // 4. POST to New Relic Insights\n    // Note: Event API has a 1MB payload limit. If there are 1000s of trains, \n    // you might need to chunk this, but for Irish Rail, one batch is usually fine.\n    const nrResponse = await $http.post({\n        url: NR_EVENT_API_URL,\n        headers: {\n            'Api-Key': NR_INSERT_KEY,\n            'Content-Type': 'application/json'\n        },\n        body: JSON.stringify(customEvents)\n    });\n\n    assert.equal(nrResponse.statusCode, 200, `Failed to send events: $${nrResponse.body}`);\n    console.log(`Successfully sent $${customEvents.length} \"LiveTrain\" events to New Relic.`);\n}\n\n// Start the monitor\nrunMonitor().catch(err => {\n    console.error('Monitor Failed:', err.message);\n    process.exit(1);\n});"
  script_language                         = "JAVASCRIPT"
  status                                  = "ENABLED"
  type                                    = "SCRIPT_API"

}
