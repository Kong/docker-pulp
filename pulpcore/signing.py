from pulpcore.app.models.content import AsciiArmoredDetachedSigningService

NAME = "sign-metadata-v1"

# read an already exported public key
with open("/tmp/public.key") as key:
    with open("/tmp/public.fpr") as fpr:
        fingerprint = fpr.read().rstrip("\n")
        service_name = f"{NAME}-{fingerprint}"
        try:
            AsciiArmoredDetachedSigningService.objects.get(name=service_name)
        except AsciiArmoredDetachedSigningService.DoesNotExist:
            print(f"Registring Signing service {service_name}")
            AsciiArmoredDetachedSigningService.objects.create(
                name=service_name,
                public_key=key.read(),
                pubkey_fingerprint=fingerprint,
                script="/app/venv/bin/sign-metadata",
            )
        else:
            print(f"Signing service {service_name} already present")
