@import com.keremgokhan.blog.models.User
@param User currentUser
@param Boolean isAuthenticated = true
@param String error = null
@param String csrfToken
@param String today

@template.layouts.blog(title = "New post", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    <link rel="stylesheet" href="https://unpkg.com/easymde/dist/easymde.min.css">
    <style>
        /* Match blog dark theme */
        .EasyMDEContainer .CodeMirror {
            background: #111111;
            color: #FFF;
            border: 1px solid #333;
            font-family: "Raleway", "HelveticaNeue", "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-size: 1.5rem;
            line-height: 1.6;
        }
        .CodeMirror-cursor {
            border-left-color: #FFF;
        }
        .CodeMirror-selected {
            background: #333 !important;
        }
        .editor-toolbar,
        .editor-preview-active-side .editor-toolbar,
        .editor-preview-active .editor-toolbar {
            background: #111111 !important;
            border-color: #333 !important;
            opacity: 1;
        }
        .editor-toolbar a,
        .editor-toolbar button {
            color: #DDD !important;
            opacity: 1;
        }
        .editor-toolbar a:hover,
        .editor-toolbar a.active,
        .editor-toolbar button:hover,
        .editor-toolbar button.active {
            background: #333 !important;
            color: #FFF !important;
            border-color: #555 !important;
            opacity: 1;
        }
        .editor-toolbar i.separator {
            border-color: #444;
        }
        .editor-preview,
        .editor-preview-side {
            background: #111111 !important;
            color: #FFF;
            border-color: #333;
        }
        /* Fullscreen mode */
        .CodeMirror-fullscreen,
        .editor-preview-side.editor-preview-active-side {
            background: #111111 !important;
        }
        .editor-statusbar {
            color: #666;
        }
        .EasyMDEContainer .CodeMirror-scroll {
            min-height: 300px;
        }
    </style>

    <form action="/post" method="POST">
        <input type="hidden" name="csrf_token" value="${csrfToken}">
        <div class="row">
            <div class="twelve columns">
                <input class="borderless title-input" name="title" type="text" placeholder="You can enter a title here." autofocus>
            </div>
        </div>
        <div class="row">
            <div class="twelve columns">
                <textarea id="body" name="body"></textarea>
            </div>
        </div>
        <div class="row">
            <div class="twelve columns">
                <input class="button-primary" type="submit" value="Post">
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
    </script>
`)
