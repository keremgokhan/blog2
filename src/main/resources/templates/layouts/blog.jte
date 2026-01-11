@import com.keremgokhan.blog.models.User
@param String title = "Blog"
@param User? currentUser = null
@param Boolean isAuthenticated = false
@param String today
@param gg.jte.Content content

@template.layouts.default(title = title, content = @`
    <div class="container">
        <div class="row">
            <div class="twelve columns title">
                <a href="/"><h3 title='"I am human, nothing human is alien to me." Publius Terentius Afer'>Homo sum, humani nihil a me alienum puto</h3></a>
            </div>
        </div>
        @if(isAuthenticated)
        <div class="row">
            <div class="twelve columns">
                <nav style="margin-bottom: 2rem;">
                    <a href="/admin">Admin</a> |
                    <a href="/admin/create">New Post</a> |
                    <a href="/admin/logout">Logout</a>
                </nav>
            </div>
        </div>
        @endif
        ${content}
    </div>

<div class="container">
    <div class="row footer">
        <div class="twelve columns">
            <span>${today}</span>
        </div>
    </div>
</div>
`)
