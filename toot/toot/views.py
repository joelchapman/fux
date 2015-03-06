from soundshare.models import Sound, Comment
from django.http import HttpResponse
from django.core import serializers
from django.shortcuts import get_object_or_404
import logging
from django.views.decorators.csrf import csrf_exempt
import datetime
from django.conf import settings

logger = logging.getLogger(__name__)

def sounds(request):
    sounds = Sound.objects.all().order_by('-pub_date')
    json_serializer = serializers.get_serializer("json")()
    output = json_serializer.serialize(sounds, ensure_ascii=False)
    return HttpResponse(output, content_type="application/json")

@csrf_exempt
def sound(request):
    logging.debug(request.POST)
    logging.debug("NAME: %s", request.POST["name"])
    try:
        if request.POST:
            sound = Sound(name=request.POST["name"], 
                          description=request.POST["description"],
                          udid=request.POST["udid"],
                          lat=request.POST["lat"],
                          long=request.POST["long"],
                          pub_date=datetime.datetime.now(),
                          likes=0)
            file = request.FILES["soundfile"]
            sound.path = file.name
            destination = open(settings.MEDIA_ROOT + file.name, 'wb+')
            for chunk in file.chunks():
                destination.write(chunk)
            destination.close()
            sound.save()
            logging.debug("this is the sound id: %d", sound.id)
            sound_id = sound.id
    except Exception, e:
        logging.debug(e)
    else:
        sound = Sound.objects.filter(id=sound_id)
        json_serializer = serializers.get_serializer("json")()
        output = json_serializer.serialize(sound, ensure_ascii=False)
        return HttpResponse(output, content_type="application/json")
