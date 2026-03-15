@import com.keremgokhan.blog.models.User
@import java.util.List
@import java.util.Map
@param User currentUser
@param Boolean isAuthenticated = true
@param String today
@param List<Map<String, Object>> drafts
@param List<Map<String, Object>> archived
@param String csrfToken
@param String error = null

@template.layouts.blog(title = "Admin", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <div class="row">
        <div class="twelve columns">
            <h5>Welcome back, ${currentUser.getName()}.</h5>
        </div>
    </div>
    <div class="row" style="margin-top: 0.5rem;">
        <div class="twelve columns">
            <a href="/admin/create" class="button">New Post</a>
            <a href="/admin/prompt" class="button" style="margin-left: 1rem;">AI Prompt</a>
        </div>
    </div>

    @if(!drafts.isEmpty())
    <div class="row" style="margin-top: 2rem;">
        <div class="twelve columns">
            <h6 style="color: #AAA; letter-spacing: 0.1em; text-transform: uppercase; font-size: 1.1rem;">Drafts</h6>
        </div>
    </div>
    @for(var post : drafts)
    <div class="row">
        <div class="ten columns">
            <a href="/post/${post.get("id").toString()}/edit">${post.get("title").toString()}</a>
        </div>
    </div>
    @endfor
    @endif

    @if(!archived.isEmpty())
    <div class="row" style="margin-top: 2rem;">
        <div class="twelve columns">
            <h6 style="color: #AAA; letter-spacing: 0.1em; text-transform: uppercase; font-size: 1.1rem;">Archived</h6>
        </div>
    </div>
    @for(var post : archived)
    <div class="row">
        <div class="ten columns">
            <span style="color: #666;">${post.get("title").toString()}</span>
        </div>
        <div class="two columns">
            <form action="/post/${post.get("id").toString()}/restore" method="POST" style="display:inline;">
                <input type="hidden" name="csrf_token" value="${csrfToken}">
                <button type="submit">Restore</button>
            </form>
        </div>
    </div>
    @endfor
    @endif
`)
