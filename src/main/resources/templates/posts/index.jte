@import com.keremgokhan.blog.models.User
@param List<Map<String, Object>> posts
@param User? currentUser = null
@param Boolean isAuthenticated = false
@param String today

@template.layouts.blog(title = "Pseudorandom posts on everything.", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    @for(var post : posts)
        <div class="row">
            <div class="twelve columns">
                <h5>
                    <a href="/post/${post.get("id")}" style="text-decoration: none; color: white;">
                        ${post.get("title")}
                    </a>
                </h5>
                <p style="color: #ccc; font-size: 0.9rem;">
                    <span style="float: right;">${post.get("date")}</span>
                </p>
            </div>
        </div>
        <div class="row marginbottom">
            <div class="twelve columns">
                <p>$unsafe{post.get("body")}</p>
            </div>
        </div>
    @endfor

    @if(posts.isEmpty())
        <p style="color: #999;">No posts yet.</p>
    @endif
`)
