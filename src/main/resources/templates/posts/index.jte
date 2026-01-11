@import com.keremgokhan.blog.models.User
@import java.util.List
@import java.util.Map
@param List<Map<String, Object>> posts
@param User currentUser = null
@param Boolean isAuthenticated = false

@template.layouts.blog(currentUser = currentUser, isAuthenticated = isAuthenticated, content = @`
    @for(var post : posts)
        <div class="post" style="margin-bottom: 3rem;">
            <h5>
                <a href="/post/${post.get("id").toString()}" style="text-decoration: none; color: white;">
                    ${post.get("title").toString()}
                </a>
            </h5>
            <p style="color: #ccc; font-size: 0.9rem;">
                <span style="float: right;">${post.get("date").toString()}</span>
            </p>
            <div style="margin-top: 1rem;">
                $unsafe{post.get("body").toString()}
            </div>
        </div>
    @endfor

    @if(posts.isEmpty())
        <p style="color: #999;">No posts yet.</p>
    @endif
`)
