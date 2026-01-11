@import com.keremgokhan.blog.models.User
@param String title = "Pseudorandom texts on everything."
@param User currentUser = null
@param Boolean isAuthenticated = false
@param gg.jte.Content content

@template.layouts.default(title = title, content = @`
    <div class="container">
        <div class="row">
            <div class="twelve columns" style="margin-top: 10%">
                <h4 title='"I am human, nothing human is alien to me." Publius Terentius Afer'><a href="/" style="text-decoration: none; color: white;">Homo sum, humani nihil a me alienum puto</a></h4>
                @if(isAuthenticated)
                <nav style="margin-bottom: 2rem;">
                    <a href="/admin">Admin</a> |
                    <a href="/admin/create">New Post</a> |
                    <a href="/admin/logout">Logout</a>
                </nav>
                @endif


                ${content}

                <footer style="margin-top: 4rem; padding-top: 2rem; border-top: 1px solid #333;">
                    <p style="font-size: 0.9rem; color: #999;">
                        &copy; ${java.time.Year.now().getValue()} Kerem and AI
                    </p>
                </footer>
            </div>
        </div>
    </div>
`)
