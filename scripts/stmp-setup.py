import os
from plone import api
from zope.component.hooks import setSite
setSite(portal)
api.portal.set_registry_record('plone.smtp_host', unicode(os.environ.get('SMTP_HOST', 'smtp.mailgun.org'), "utf-8") )
api.portal.set_registry_record('plone.smtp_port',int(os.environ.get('SMTP_PORT', 587)))
api.portal.set_registry_record('plone.smtp_userid', unicode(os.environ.get('SMTP_USERNAME', 'noreply@example.com'), "utf-8"))
api.portal.set_registry_record('plone.smtp_pass', unicode(os.environ.get('SMTP_PASSWORD', 'changethis'), "utf-8"))
api.portal.set_registry_record('plone.email_from_name', unicode(os.environ.get('SMTP_SENDER_NAME', 'Example Plone Site'), "utf-8"))
api.portal.set_registry_record('plone.email_from_address',os.environ.get('SMTP_SENDER_EMAIL', 'noreply@example.com'))