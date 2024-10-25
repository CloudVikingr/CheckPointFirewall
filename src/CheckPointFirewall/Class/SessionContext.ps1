class SessionContext {
    [string]$AuthToken

    SessionContext([string]$authToken) {
        $this.AuthToken = $authToken
    }
}