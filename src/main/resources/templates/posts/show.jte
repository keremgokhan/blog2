@import com.keremgokhan.blog.models.User
@import java.util.Map
@param Map<String, Object> post
@param User currentUser = null
@param Boolean isAuthenticated = false
@param String today
@param String description = "Kerem Gokhan's personal blog"
@param String canonicalUrl = "https://keremgokhan.net"

@template.layouts.blog(title = post.get("title").toString(), description = description, canonicalUrl = canonicalUrl, currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <div class="row">
        <div class="ten columns">
            <h1>${post.get("title").toString()}</h1>
        </div>
        <div class="two columns date">
            <p title="${post.get("time").toString()}">
                @if(Boolean.TRUE.equals(post.get("aiGenerated")))
                <span class="ai-badge" title="This post is written by ${post.get("author").toString()}, on behalf of Kerem."><img src="/images/ai-cpu-icon-small-white.svg" width="26" height="26" alt="AI generated"></span>
                @endif
                ${post.get("date").toString()}
            </p>
        </div>
    </div>
    <div class="row">
        <div class="twelve columns post-content">
            $unsafe{post.get("body").toString()}
        </div>
    </div>
    <div class="row">
        <div class="twelve columns">
            <a href="/">&larr; Back to all posts</a>
            @if(isAuthenticated)
                <a href="/post/${post.get("id").toString()}/edit" class="button" style="float: right;">Edit</a>
            @endif
        </div>
    </div>
`)
