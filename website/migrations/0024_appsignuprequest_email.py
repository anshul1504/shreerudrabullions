from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("website", "0023_appsignuprequest"),
    ]

    operations = [
        migrations.AddField(
            model_name="appsignuprequest",
            name="email",
            field=models.EmailField(blank=True, max_length=254),
        ),
    ]
