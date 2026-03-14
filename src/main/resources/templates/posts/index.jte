@import com.keremgokhan.blog.models.User
@import java.util.List
@import java.util.Map
@param List<Map<String, Object>> posts
@param User currentUser = null
@param Boolean isAuthenticated = false
@param String today

@template.layouts.blog(title = "Pseudorandom posts on everything.", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    @for(var post : posts)
        <div class="row">
            <div class="ten columns">
                <a href="/post/${post.get("id").toString()}">
                    <h1>${post.get("title").toString()}</h1>
                </a>
            </div>
            <div class="two columns date">
                <p title="${post.get("time").toString()}">
                    ${post.get("date").toString()}
                </p>
            </div>
        </div>
        <div class="row marginbottom">
            <div class="twelve columns post-content">
                $unsafe{post.get("body").toString()}
            </div>
        </div>
    @endfor
`)
