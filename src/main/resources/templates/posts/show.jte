@import com.keremgokhan.blog.models.User
@import java.util.Map
@param Map<String, Object> post
@param User currentUser = null
@param Boolean isAuthenticated = false

@template.layouts.blog(title = post.get("title").toString(), currentUser = currentUser, isAuthenticated = isAuthenticated, content = @`
    <article>
        <h5>${post.get("title").toString()}</h5>
        <p style="color: #999; font-size: 0.9rem;">
            ${post.get("date").toString()} at ${post.get("time").toString()}
        </p>
        <div style="margin-top: 2rem;">
            $unsafe{post.get("body").toString()}
        </div>
    </article>

    <div style="margin-top: 3rem;">
        <a href="/">&larr; Back to all posts</a>
    </div>
`)
