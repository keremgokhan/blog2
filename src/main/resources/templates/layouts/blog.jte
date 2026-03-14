@import com.keremgokhan.blog.models.User
@param String title = "Blog"
@param String description = "Kerem Gokhan's personal blog"
@param String canonicalUrl = "https://keremgokhan.net"
@param User currentUser = null
@param Boolean isAuthenticated = false
@param String today
@param gg.jte.Content content

@template.layouts.default(title = title, description = description, canonicalUrl = canonicalUrl, content = @`
    <div class="container">
        <div class="row">
            <div class="twelve columns title${isAuthenticated ? " logged" : ""}">
                <a href="/"><h3 title='"I am human, nothing human is alien to me." Publius Terentius Afer'>Homo sum, humani nihil a me alienum puto</h3></a>
            </div>
        </div>
        @if(isAuthenticated)
        <nav class="row navbar">
            <ul class="navbar-list">
                <li class="two columns navbar-item">
                    <a href="/admin/create">New</a>
                </li>
                <li class="two columns navbar-item">
                    <a href="/admin">Admin</a>
                </li>
                <li class="two columns navbar-item">
                    <a href="/admin/logout">Logout</a>
                </li>
            </ul>
        </nav>
        @endif
    </div>
    <div class="container">
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
