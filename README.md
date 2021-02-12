# object-detection ml backend for Label Studio
Object-detection ML backend for label studio

[![Run](https://staroid.com/api/run/button.svg)](https://staroid.com/api/run)

## Settings

This ML backend works with following labeling config setting (Label Studio -> Settings -> Labeling config)

```
<View>
  <Image name="image" value="$image"/>
  <RectangleLabels name="label" toName="image">
    <Label value="Airplane" background="green"/>
    <Label value="Car" background="blue"/>
  </RectangleLabels>
</View>
```

see https://labelstud.io/tutorials/object-detector.html#The-full-list-of-COCO-labels for full supported labels.


## Development

Run locally with

```
skaffold dev -pminikube --port-forward
```
