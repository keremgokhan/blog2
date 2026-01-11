@param String message = "Internal server error"
@param String today

@template.layouts.blog(title = "500 Internal Server Error", today = today, content = @`
    <h5>500 - Internal Server Error</h5>
    <p>Something went wrong on our end. Please try again later.</p>
    <p><a href="/">Return to home page</a></p>
`)
