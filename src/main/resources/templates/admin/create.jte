@import com.keremgokhan.blog.models.User
@param User currentUser
@param Boolean isAuthenticated = true
@param String error = null
@param String csrfToken
@param String today

@template.layouts.blog(title = "New post", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <form action="/post" method="POST">
        <input type="hidden" name="csrf_token" value="${csrfToken}">
        <div class="row">
            <div class="twelve columns">
                <input class="borderless title-input" name="title" type="text" placeholder="You can enter a title here." autofocus>
            </div>
        </div>
        <div class="row">
            <div class="twelve columns">
                <textarea class="borderless post-body" name="body" placeholder="Here you can enter AN ENTIRE MESSAGE CONTENT. No joking. This is the future."></textarea>
                <small style="color: #999;">HTML is allowed but will be sanitized for security</small>
            </div>
        </div>
        <div class="row">
            <div class="twelve columns">
                <input class="button-primary" type="submit" value="Post">
                <a href="/admin" class="button" style="margin-left: 1rem;">Cancel</a>
            </div>
        </div>
    </form>
    @if(error != null)
    <div class="row">
        <div class="ten columns">
            <p>
                @if(error.equals("empty"))
                    Please fill in both title and body
                @elseif(error.equals("failed"))
                    Failed to create post. Please try again.
                @else
                    ${error}
                @endif
            </p>
        </div>
    </div>
    @endif
`)
