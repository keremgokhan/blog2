@import com.keremgokhan.blog.models.User
@param User currentUser
@param Boolean isAuthenticated = true
@param String today
@param String prompt
@param String csrfToken
@param Boolean saved = false

@template.layouts.blog(title = "AI Prompt", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <div class="row">
        <div class="twelve columns">
            <h5>AI Generation Prompt</h5>
        </div>
    </div>

    @if(saved)
    <div class="row">
        <div class="twelve columns">
            <p style="color: #2ecc71;">Prompt saved.</p>
        </div>
    </div>
    @endif

    <form action="/admin/prompt" method="POST">
        <input type="hidden" name="csrf_token" value="${csrfToken}">
        <div class="row">
            <div class="twelve columns">
                <textarea name="prompt" style="width: 100%; min-height: 600px; font-family: 'Courier New', monospace; font-size: 1.3rem; line-height: 1.6; background: #000; color: #DDD; border: none; border-bottom: 1px solid #444; padding: 1rem 0; resize: vertical;">${prompt}</textarea>
            </div>
        </div>
        <div class="row" style="margin-top: 1rem;">
            <div class="twelve columns">
                <input class="button-primary" type="submit" value="Save">
                <a href="/admin" class="button" style="margin-left: 1rem;">Cancel</a>
            </div>
        </div>
    </form>
`)
