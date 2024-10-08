{
  Copyright 1999-2005 ImageMagick Studio LLC, a non-profit organization
  dedicated to making software imaging solutions freely available.
  
  You may not use this file except in compliance with the License.
  obtain a copy of the License at
  
    http://www.imagemagick.org/script/license.php
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  ImageMagick image compare methods.
}

//#include "magick/image.h"

type
 MetricType = (
  UndefinedErrorMetric,
  AbsoluteErrorMetric,
  FuzzErrorMetric,
  MeanAbsoluteErrorMetric,
  MeanErrorPerPixelErrorMetric,
  MeanSquaredErrorMetric,
  NormalizedCrossCorrelationErrorMetric,
  PeakAbsoluteErrorMetric,
  PeakSignalToNoiseRatioErrorMetric,
  PerceptualHashErrorMetric,
  RootMeanSquaredErrorMetric,
  StructuralSimilarityErrorMetric,
  StructuralDissimilarityErrorMetric
 );

{extern MagickExport Image
  *CompareImageChannels(Image *,const Image *,const ChannelType,
    const MetricType,double *,ExceptionInfo *),
  *CompareImages(Image *,const Image *,const MetricType,double *,
    ExceptionInfo *);

extern MagickExport MagickBooleanType
  CompareImageCommand(ImageInfo *,int,char **,char **,ExceptionInfo *),
  GetImageChannelDistortion(Image *,const Image *,const ChannelType,
    const MetricType,double *,ExceptionInfo *),
  GetImageDistortion(Image *,const Image *,const MetricType,double *,
    ExceptionInfo *),
  IsImagesEqual(Image *,const Image *);}

