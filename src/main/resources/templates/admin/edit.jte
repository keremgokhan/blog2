@import com.keremgokhan.blog.models.User
@import java.util.Map
@param Map<String, Object> post
@param User currentUser
@param Boolean isAuthenticated = true
@param String error = null
@param String csrfToken
@param String today

@template.layouts.blog(title = "Edit post", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <link rel="stylesheet" href="https://unpkg.com/easymde/dist/easymde.min.css">
    <link rel="stylesheet" href="/css/editor.css">

    <form action="/post/${post.get("id").toString()}/edit" method="POST">
        <input type="hidden" name="csrf_token" value="${csrfToken}">
        <div class="row">
            <div class="twelve columns">
                <input class="borderless title-input" name="title" type="text" value="${post.get("title").toString()}" autofocus>
            </div>
        </div>
        <div class="row">
            <div class="twelve columns">
                <textarea id="body" name="body">${post.get("body").toString()}</textarea>
            </div>
        </div>
        <input type="hidden" name="draft" id="draft-flag" value="false">
        <div class="row">
            <div class="twelve columns">
                <input class="button-primary" type="submit" value="Save">
                <button type="submit" onclick="document.getElementById('draft-flag').value='true'" style="margin-left: 1rem;">Save as Draft</button>
                <a href="/post/${post.get("id").toString()}" class="button" style="margin-left: 1rem;">Cancel</a>
                <button type="button" onclick="document.getElementById('archive-form').submit(); return false;" style="margin-left: 1rem;">Archive</button>
            </div>
        </div>
    </form>

    <form id="archive-form" action="/post/${post.get("id").toString()}/archive" method="POST" style="display:none;">
        <input type="hidden" name="csrf_token" value="${csrfToken}">
    </form>
    @if(error != null)
    <div class="row">
        <div class="ten columns">
            <p>
                @if(error.equals("empty"))
                    Please fill in both title and body
                @elseif(error.equals("failed"))
                    Failed to save. Please try again.
                @else
                    ${error}
                @endif
            </p>
        </div>
    </div>
    @endif

    <script src="https://unpkg.com/easymde/dist/easymde.min.js"></script>
    <script>
        var easyMDE = new EasyMDE({
            element: document.getElementById('body'),
            spellChecker: false,
            lineWrapping: true,
            toolbar: [
                "bold", "italic", "heading", "|",
                "quote", "unordered-list", "ordered-list", "|",
                "link", "code", "|",
                "preview", "side-by-side", "fullscreen", "|",
                "guide"
            ]
        });
    </script>
`)
