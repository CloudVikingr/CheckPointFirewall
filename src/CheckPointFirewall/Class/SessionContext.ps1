class SessionContext {
    [securestring]$AuthToken

    SessionContext([securestring]$authToken) {
        $this.AuthToken = $authToken
    }
}