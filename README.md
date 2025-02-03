# zindi-kyusera-kuyesera-ai-ddadc
Kuyesera AI Disaster Damage and Displacement Challenge on Zindi


# Overview
This submission is an ensemble of several different methods of detecting buildings in the given satellite imagery.
* Three different Vision Language Models (VLMs) are used, each multiple times to smooth the distribution:
  * llama3.2-11b: full test "pre" image, cropped to visible light
  * pixtral-12b: half of test "pre" image after cropping, yielding a more even image
  * qwen2vl-72b: full test "pre" image, cropped to visible light
* In addition, a detection model is built from YOLO-V8 using the training data we were given and applied to the "pre" images.
* A related detection model and follow-on segmentation model was used as well, from a public HuggingFace space. This was used "pre" and "post", and the max of the two was used.
* Finally, AWS Athena was used to include building data from the daylight_earth ASDI data set (https://daylightmap.org/).

The final submission had only 

# Data Flow
* Image Preparation
  * Test TIF: crop to visible light (remove black portion), export JPGs
  * Test JPGs split in left/right.
  * Train JPGs: Zoom 2x, export PNGs. Zoom to match lat/lon:pixel ratio of test images (was about 1.8x - 2.5x)
* Zero Shot VLMs
  * llama 3.2 11b
    * input: full "pre" JPG images
    * output: text file for each result; 2+ iterations averaged together
  * qwenvl-72b: full "pre" JPG images
    * input: full test/pre images
    * output: text file for each result; 2+ iterations averaged together
  * pixtral-12b: add together results for left image and right image (also "pre" only)
    * input: left image and right image (also "pre" only)
    * output: text file for each result; add together results
* YoloV8x, fine tuned
  * Input: full "pre" JPG images
  * Output: 348 CSVs, used only to count
* Public HuggingFace Space (fine tuned): Gradio API
  * Input: pre and post JPGs
  * Output: COCO format JSON files, used to count detections
* Daylight OpenStreetView via ASDI on Athena
  * Input: daylight table, test_coords.csv
  * Output: CSV with building count of overlapping lat/lon per image
* Each individual method's output text or CSV files were aggregated, for an independent submission as "no damage" detection counts.
* Ensemble:
  * 50% llama 3.2 11b
  * 10% pixtral-12b 
  * 8% q72 double
  * 20% hf max
  * 10% detection
  * 2% athena
 

# VLM Results
All VLM results were originally captured with VLLM in the first couple weeks of the competition. I then pursued detection models. Toward the end, when using the same VLLM interface, I started getting unstable results. Code is provided for the three primary models I was using, but through separate means. Simple use of VLLM on a large enough machine to host Qwen-72B (or it can be removed for ~0.03 score reduction) makes the three models interchangeable, faster, and simpler to manage. However, I cannot do so on my personal system (RTX 4090, 24GB) nor AWS or HuggingFace. So the final solution contains more disparate methods than one would like, but as these are all untouched models used in zero shot mode, there are many ways to use all of them. I am presenting inferencing using a local llama11b via transformers, free use of pixtral through Mistral's API, and together.ai's hosting of QwenVL-72B.

# Discarded Attempts
llama-90b and qwen7b were used, but produced independent scores too far off to try including in the ensemble. Most models other than llama-11b did fairly poor, but were helped by additional runs to smooth predictions. Llama-11b got worse when using split left/right images and started wildly overcounting smaller items, an effect that was somewhat mitigated by using the ensemble to curb outlier predictions (though the private LB shows this was not actually useful, only the public side).

I tried directly using a ViT as well, the part doing most of the work within much larger VLMs. Owlvit did not produce useful results with a few test images and was discarded.

I tried aligning the high-res segmentations from the public HF model and trying to identify differences, but it was far off. I also tried simple image differencing measures to detect the most obvious of flood situations, and these were also unusable.

# Next Steps
This still feels like a problem for a strong detection model, alignment between pre/post, and then a detection of the differences. My models were not strong enough. All methods struggled visibly with overcounting (often landscape features) and undercounting.
I had decent results with early tests against several storm images and several non-storm issues using the VLMs with basic prompts to cautiously identify storm damage using an image that contained "pre" on top and "post" on bottom. When running the same three models, the three images with storm damage produced 2-3 positive results, and the three images without storm damage procued 0-1 positive results from the three VLMs. This was an encouraging result. However, when I went back to it on the last weekend of the competition, running through all 348 images produced unusable results. I fear something had gone wrong with the VLLM instance I was using, as those previous results that were encouraging were producing near-constant output, often citing 15 damaged buildings in all images. With more time, this method looked useful. Instead, I removed all damage predictions from my solution on the final day as I could not seem to reproduce the results.
