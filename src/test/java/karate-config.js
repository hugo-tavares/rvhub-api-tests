function fn() {
	var env = karate.env; // get system property 'karate.env'
	if (!env) {
		env = 'dev';
	}
	karate.log('Environment:', env);
	karate.configure('connectTimeout', 6000000);
	karate.configure('readTimeout', 6000000);
	var config = {
		env : env,
		authUrl : 'https://auth.dev.rvhub.com.br/oauth2/token',
		baseUrl: 'https://api.dev.rvhub.com.br',
		registeredStoreUsername: 'RETIRADO',
		registeredStorePassword: 'RETIRADO'
	}

	return config;
}