@param String title = "Blog"
@param gg.jte.Content content

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>${title}</title>
    <meta name="description" content="Kerem Gokhan's personal blog">
    <meta name="author" content="Kerem Gokhan">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSS -->
    <link rel="stylesheet" href="/css/normalize.css">
    <link rel="stylesheet" href="/css/skeleton.css">
    <link rel="stylesheet" href="/css/thestyle.css">

    <!-- Favicon -->
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <link rel="manifest" href="/manifest.json">
    <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">
    <meta name="theme-color" content="#ffffff">

    <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}

        function loadGA() {
            var s = document.createElement('script');
            s.async = true;
            s.src = 'https://www.googletagmanager.com/gtag/js?id=G-T4HLL5RZGS';
            document.head.appendChild(s);
            gtag('js', new Date());
            gtag('config', 'G-T4HLL5RZGS');
        }

        if (localStorage.getItem('cookie_consent') === 'accepted') {
            loadGA();
        }
    </script>
</head>
<body>
    ${content}

    <div id="cookie-banner" style="display:none;">
        <span>This site uses cookies for analytics.</span>
        <div class="cookie-buttons">
            <button onclick="cookieConsent('declined')">Decline</button>
            <button onclick="cookieConsent('accepted')">Accept</button>
        </div>
    </div>

    <style>
        #cookie-banner {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: #111111;
            border-top: 1px solid #333;
            padding: 1.2rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 1.4rem;
            color: #AAA;
            z-index: 1000;
        }
        .cookie-buttons {
            display: flex;
            gap: 1rem;
            flex-shrink: 0;
            margin-left: 2rem;
        }
        .cookie-buttons button {
            font-size: 1.2rem;
            padding: 0.4rem 1.2rem;
            cursor: pointer;
            background: transparent;
            color: #AAA;
            border: 1px solid #444;
            border-radius: 0;
            letter-spacing: 0.05em;
        }
        .cookie-buttons button:last-child {
            color: #FFF;
            border-color: #FFF;
        }
        .cookie-buttons button:hover {
            opacity: 0.6;
        }
    </style>

    <script>
        function cookieConsent(choice) {
            localStorage.setItem('cookie_consent', choice);
            document.getElementById('cookie-banner').style.display = 'none';
            if (choice === 'accepted') loadGA();
        }

        if (!localStorage.getItem('cookie_consent')) {
            document.getElementById('cookie-banner').style.display = 'flex';
        }
    </script>
</body>
</html>
