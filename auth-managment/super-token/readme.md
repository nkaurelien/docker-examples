# Intro

Supertoken is an alternative to Auth0 / Firebase Auth / AWS Cognito, as we know Auth0 is a great product but it is very costly. I think it is best bet to self-host it and start saving a lot of $.

Supertoken provides the auth with Email/password, Passwordless (OTP or Magic link-based), Social / OAuth 2.0, etc. Additionally, it is also providing support to Access control, Session management, and User management. You can start using the self-hosted or their managed cloud plan to implement the authentication with your apps.

# RUN

docker run -p 3567:3567 -d registry.supertokens.io/supertokens/supertokens-mysql:9.2.2

# LINKS

- https://supertokens.com/docs/deployment/self-hosting/with-docker