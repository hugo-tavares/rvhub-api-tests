@shared @login
Feature: Authentication as a registered store
	Background:
		* def basicAuth = call read('classpath:aplic/rvhub/shared/basic-auth.js') { username: #(registeredStoreUsername), password: #(registeredStorePassword) }
	Scenario: Authentication
		Given url authUrl
		And header Authorization = basicAuth
		And header Content-Type = 'application/x-www-form-urlencoded'
		And param grant_type = 'client_credentials'
		Given request ''
		When method POST
		Then status 200