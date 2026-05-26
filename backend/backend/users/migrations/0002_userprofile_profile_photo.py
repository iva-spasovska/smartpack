# Generated manually because the local Python launcher was unavailable.

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprofile',
            name='profile_photo',
            field=models.FileField(
                blank=True,
                null=True,
                upload_to='profile_photos/',
            ),
        ),
    ]
