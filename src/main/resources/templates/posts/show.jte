@import com.keremgokhan.blog.models.User
@import java.util.Map
@param Map<String, Object> post
@param User currentUser = null
@param Boolean isAuthenticated = false
@param String today

@template.layouts.blog(title = post.get("title").toString(), currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <div class="row">
        <div class="ten columns">
            <h5>${post.get("title").toString()}</h5>
        </div>
        <div class="two columns date">
            <p title="${post.get("time").toString()}">
                ${post.get("date").toString()}
            </p>
        </div>
    </div>
    <div class="row">
        <div class="twelve columns">
            $unsafe{post.get("body").toString()}
        </div>
    </div>
    <div class="row">
        <div class="twelve columns">
            <a href="/">&larr; Back to all posts</a>
        </div>
    </div>
`)
