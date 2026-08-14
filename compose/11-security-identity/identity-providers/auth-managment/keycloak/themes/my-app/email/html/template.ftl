<#macro emailLayout>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { margin: 0; padding: 0; background-color: #f5f5f5; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; margin-top: 40px; margin-bottom: 40px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .header { background-color: #2563eb; padding: 30px; text-align: center; }
    .header h1 { color: #ffffff; margin: 0; font-size: 24px; font-weight: 600; }
    .content { padding: 30px; color: #333333; line-height: 1.6; }
    .btn { display: inline-block; background-color: #2563eb; color: #ffffff !important; text-decoration: none; padding: 12px 30px; border-radius: 6px; font-weight: 600; margin: 20px 0; }
    .btn:hover { background-color: #1d4ed8; }
    .footer { padding: 20px 30px; text-align: center; color: #999999; font-size: 12px; border-top: 1px solid #eeeeee; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>${kcSanitize(realmName)?no_esc}</h1>
    </div>
    <div class="content">
      <#nested>
    </div>
    <div class="footer">
      <p>&copy; ${.now?string('yyyy')} ${kcSanitize(realmName)?no_esc}. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
</#macro>
