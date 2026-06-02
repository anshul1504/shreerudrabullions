from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("website", "0024_appsignuprequest_email"),
    ]

    operations = [
        migrations.AddField(
            model_name="appsignuprequest",
            name="fcm_token",
            field=models.TextField(blank=True),
        ),
    ]
