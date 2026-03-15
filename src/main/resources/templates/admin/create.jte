@import com.keremgokhan.blog.models.User
@param User currentUser
@param Boolean isAuthenticated = true
@param String error = null
@param String csrfToken
@param String today

@template.layouts.blog(title = "New post", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <link rel="stylesheet" href="https://unpkg.com/easymde/dist/easymde.min.css">
    <link rel="stylesheet" href="/css/editor.css">

    <div class="row" style="margin-bottom: 1.5rem;">
        <div class="twelve columns">
            <select id="ai-model" style="display: inline-block; width: auto; margin-right: 0.5rem; padding: 0 0.8rem; height: 38px; border-bottom: 1px solid #DDD; background: #000; color: #DDD;">
                <option value="claude-sonnet-4-6">Sonnet 4 — Smart</option>
                <option value="claude-opus-4-6">Opus 4 — Powerful</option>
                <option value="claude-haiku-4-5-20251001">Haiku 4.5 — Fast</option>
            </select>
            <button type="button" id="ai-generate-btn">Generate with AI</button>
            <span id="ai-error" style="color: #c0392b; margin-left: 1rem; display: none;"></span>
        </div>
    </div>

    <form action="/post" method="POST">
        <input type="hidden" name="csrf_token" value="${csrfToken}">
        <input type="hidden" name="ai_generated" id="ai-generated-flag" value="false">
        <input type="hidden" name="ai_model" id="ai-model-flag" value="">
        <div class="row">
            <div class="twelve columns">
                <input class="borderless title-input" name="title" id="post-title" type="text" placeholder="You can enter a title here." autofocus>
            </div>
        </div>
        <div class="row">
            <div class="twelve columns">
                <textarea id="body" name="body"></textarea>
            </div>
        </div>
        <input type="hidden" name="draft" id="draft-flag" value="false">
        <div class="row">
            <div class="twelve columns">
                <input class="button-primary" type="submit" value="Post">
                <button type="submit" onclick="document.getElementById('draft-flag').value='true'" style="margin-left: 1rem;">Save as Draft</button>
                <a href="/admin" class="button" style="margin-left: 1rem;">Cancel</a>
            </div>
        </div>
    </form>
    @if(error != null)
    <div class="row">
        <div class="ten columns">
            <p>
                @if(error.equals("empty"))
                    Please fill in both title and body
                @elseif(error.equals("failed"))
                    Failed to create post. Please try again.
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
            placeholder: 'Write your post here. Markdown and HTML are both supported.',
            toolbar: [
                "bold", "italic", "heading", "|",
                "quote", "unordered-list", "ordered-list", "|",
                "link", "code", "|",
                "preview", "side-by-side", "fullscreen", "|",
                "guide"
            ]
        });

        document.getElementById('ai-generate-btn').addEventListener('click', function() {
            var btn = this;
            var model = document.getElementById('ai-model').value;
            var errorEl = document.getElementById('ai-error');

            btn.textContent = 'Generating...';
            btn.disabled = true;
            errorEl.style.display = 'none';

            var formData = new FormData();
            formData.append('csrf_token', '${csrfToken}');
            formData.append('model', model);

            fetch('/admin/ai-generate', { method: 'POST', body: formData })
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    if (data.error) {
                        errorEl.textContent = data.error;
                        errorEl.style.display = 'inline';
                    } else {
                        document.getElementById('post-title').value = data.title;
                        easyMDE.value(data.body);
                        document.getElementById('ai-generated-flag').value = 'true';
                        document.getElementById('ai-model-flag').value = model;
                    }
                })
                .catch(function() {
                    errorEl.textContent = 'Generation failed. Try again.';
                    errorEl.style.display = 'inline';
                })
                .finally(function() {
                    btn.textContent = 'Generate with AI';
                    btn.disabled = false;
                });
        });
    </script>
`)
