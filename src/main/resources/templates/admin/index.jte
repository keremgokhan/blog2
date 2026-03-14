@import com.keremgokhan.blog.models.User
@param User currentUser
@param Boolean isAuthenticated = true
@param String today

@template.layouts.blog(title = "Admin", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <div class="row">
        <div class="ten columns">
            <h5>Welcome back, ${currentUser.getName()}.</h5>
        </div>
    </div>
`)
