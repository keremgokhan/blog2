@import com.keremgokhan.blog.models.User
@import java.util.List
@import java.util.Map
@param List<Map<String, Object>> posts
@param User currentUser = null
@param Boolean isAuthenticated = false
@param String today

@template.layouts.blog(title = "Pseudorandom posts on everything.", currentUser = currentUser, isAuthenticated = isAuthenticated, today = today, content = @`
    !{String[] dinkusSymbols = new String[]{"⊙", "✦", "∴", "∞", "✧", "⋆", "☽", "⁂", "✺", "§", "∾", "❋", "𓂀"};}
    @for(int i = 0; i < posts.size(); i++)
        !{var post = posts.get(i);}
        <div class="row">
            <div class="ten columns">
                <a href="/post/${post.get("id").toString()}">
                    <h1>${post.get("title").toString()}</h1>
                </a>
            </div>
            <div class="two columns date">
                <p title="${post.get("time").toString()}">
                    ${post.get("date").toString()}
                </p>
            </div>
        </div>
        <div class="row marginbottom">
            <div class="twelve columns post-content">
                $unsafe{post.get("body").toString()}
            </div>
        </div>
        @if(i < posts.size() - 1)
            !{String dinkus = (i == 0 || i == posts.size() - 2) ? "⊕" : dinkusSymbols[(i - 1) % dinkusSymbols.length];}
            <div class="row">
                <div class="twelve columns dinkus">
                    <span>${dinkus}</span>
                </div>
            </div>
        @endif
    @endfor
`)
