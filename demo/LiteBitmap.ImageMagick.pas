unit LiteBitmap.ImageMagick;

interface

{$SCOPEDENUMS ON}
{$IFDEF MSWINDOWS}

uses
  { Delphi }
  System.SysUtils,
  System.Types,

  { Third-party }
  ImageMagick,
  ImageMagick.Wand,

  { iPub }
  LiteBitmap;

type
  EipImageMagickLiteBitmap = class(Exception);


  { IipImageMagickLiteBitmap }

  IipImageMagickLiteBitmap = interface(IipLiteBitmap)
    ['{046868D4-B8C2-4093-9A9A-36F8260C5A0A}']
  end;


  { TipImageMagickLiteBitmap }

  TipImageMagickLiteBitmap = class(TipLiteBitmap, IipImageMagickLiteBitmap, IipLiteBitmap)
  private
    FMagickWand: PMagickWand;
    procedure CheckMagick(AStatus: MagickBooleanType; const AMethodName: string);
  protected
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
  public
    constructor Create(const ABytes: TBytes); override;
    constructor Create(const ABytes: TBytes; ASrcRect: TRect); override;
    destructor Destroy; override;
    class procedure FinalizeLibrary;
    procedure Resize(AWidth, AHeight: Integer; AAlgorithm: TipScaleAlgorithm; const ExtentWidth, ExtentHeight : Integer; Gravity: GravityType;  ExtentColor:AnsiString);
    function ToBytes(AFormat: TipImageFormat; AQuality: Byte = 0): TBytes;
    class function TryInitializeLibrary: Boolean;
  end;

implementation

uses
  { Delphi }
  FMX.Types;


{ TipImageMagickLiteBitmap }

procedure TipImageMagickLiteBitmap.CheckMagick(AStatus: MagickBooleanType;  const AMethodName: string);
var
  LSeverity: ExceptionType;
  LDescriptionPAnsiChar: PAnsiChar;
  LDescription: string;
begin
  if AStatus = MagickFalse then
  begin
    LDescriptionPAnsiChar := MagickGetException(FMagickWand, @LSeverity);
    LDescription := string(AnsiString(LDescriptionPAnsiChar));
    MagickRelinquishMemory(LDescriptionPAnsiChar);
    raise EipImageMagickLiteBitmap.CreateFmt('[%s] Unexpected error ocurred. Description: %s', [AMethodName, LDescription]);
  end;
end;

constructor TipImageMagickLiteBitmap.Create(const ABytes: TBytes; ASrcRect: TRect);
begin
  Create(ABytes);
  if (ASrcRect.Width <= 0) or (ASrcRect.Height <= 0) then
  begin
    if Assigned(FMagickWand) then
      FMagickWand := DestroyMagickWand(FMagickWand);
  end
  else if Assigned(FMagickWand) then
  begin
    ASrcRect := ASrcRect * TRect.Create(0, 0, Width, Height);
    CheckMagick(MagickCropImage(FMagickWand, ASrcRect.Width, ASrcRect.Height, ASrcRect.Left, ASrcRect.Top), 'TipImageMagickLiteBitmap.Create(TBytes, TRect)');
  end
  else
    raise EipImageMagickLiteBitmap.Create('[TipImageMagickLiteBitmap.Create(TBytes, TRect)] Unexpected error (null bitmap)');
end;

constructor TipImageMagickLiteBitmap.Create(const ABytes: TBytes);
begin
  inherited Create;
  if Length(ABytes) > 0 then
  begin
    FMagickWand := NewMagickWand;
    if Assigned(FMagickWand) then
      CheckMagick(MagickReadImageBlob(FMagickWand, @(ABytes[0]), Length(ABytes)), 'TipImageMagickLiteBitmap.Create(TBytes)');
  end;
end;

destructor TipImageMagickLiteBitmap.Destroy;
begin
  if Assigned(FMagickWand) then
    FMagickWand := DestroyMagickWand(FMagickWand);
  inherited;
end;

class procedure TipImageMagickLiteBitmap.FinalizeLibrary;
begin
  FinalizeImageMagick;
end;

function TipImageMagickLiteBitmap.GetHeight: Integer;
begin
  if Assigned(FMagickWand) then
    Result := MagickGetImageHeight(FMagickWand)
  else
    Result := 0;
end;

function TipImageMagickLiteBitmap.GetWidth: Integer;
begin
  if Assigned(FMagickWand) then
    Result := MagickGetImageWidth(FMagickWand)
  else
    Result := 0;
end;

procedure TipImageMagickLiteBitmap.Resize(AWidth, AHeight: Integer;  AAlgorithm: TipScaleAlgorithm; const ExtentWidth, ExtentHeight : Integer; Gravity: GravityType;  ExtentColor:AnsiString);
var
  PW1 : PPixelWand;
  NH, NW : Integer;
begin
  if Assigned(FMagickWand) then
  begin
    PW1:= NewPixelWand();

    // The image magick support different algorithms that isn't in TipScaleAlgorithm,
    // then we will consider always the "TipScaleAlgorithm.Lanczos", because it is one of the best

    case AAlgorithm of
      TipScaleAlgorithm.FastBilinear:    CheckMagick(MagickResizeImage(FMagickWand, AWidth, AHeight, LanczosFilter, 1.0), 'TipImageMagickLiteBitmap.Resize');
      TipScaleAlgorithm.Bilinear:        CheckMagick(MagickResizeImage(FMagickWand, AWidth, AHeight, LanczosFilter, 1.0), 'TipImageMagickLiteBitmap.Resize');
      TipScaleAlgorithm.Bicubic:         CheckMagick(MagickResizeImage(FMagickWand, AWidth, AHeight, LanczosFilter, 1.0), 'TipImageMagickLiteBitmap.Resize');
      TipScaleAlgorithm.NearestNeighbor: CheckMagick(MagickResizeImage(FMagickWand, AWidth, AHeight, LanczosFilter, 1.0), 'TipImageMagickLiteBitmap.Resize');
      TipScaleAlgorithm.Lanczos:         CheckMagick(MagickResizeImage(FMagickWand, AWidth, AHeight, LanczosFilter, 1.0), 'TipImageMagickLiteBitmap.Resize');
    else
      raise EipImageMagickLiteBitmap.CreateFmt('[TipImageMagickLiteBitmap.Resize] Unknown TipScaleAlgorithm(%d)', [Ord(AAlgorithm)]);
    end;

    PixelSetColor(PW1, PAnsiChar(ExtentColor));
    MagickSetImageBackgroundColor(FMagickWand, PW1);
    // MagickSetImageGravity(FMagickWand, SouthEastGravity); // does not work

//    MagickSetImageGravity(FMagickWand, CenterGravity);
    //CheckMagick(MagickSetImageExtent(FMagickWand, 1000, 1200), 'TipImageMagickLiteBitmap.Extend'); // Ok but no PixelWand, no Gravity
    // https://stackoverflow.com/questions/43471168/magicksetimagegravity-is-not-working
    case Gravity of
      UndefinedGravity, NorthWestGravity:
        begin
          NH:=0;
          NW:=0;
        end;
      SouthWestGravity:
      begin
         NW:=0;
         NH:=Height - ExtentHeight;
      end;
      SouthEastGravity:
      begin
        NW:=Width - ExtentWidth;
        NH:=Height - ExtentHeight;
      end;
      EastGravity:
      begin
        NW:=Width - ExtentWidth;
        NH:=(Height - ExtentHeight) div 2;
      end;

      NorthGravity:
      begin
        NW:=(Width - ExtentWidth) div 2;
        NH:=0;
      end;
      NorthEastGravity:
      begin
        NW:=Width - ExtentWidth;
        NH:=0;
      end;
      WestGravity:
      begin
        NW:=0;
        NH:=(Height - ExtentHeight) div 2;
      end;
      CenterGravity:
      begin
        NW:=(Width - ExtentWidth) div 2;
        NH:=(Height - ExtentHeight) div 2;
      end;
      SouthGravity:
      begin
        NW:=(Width - ExtentWidth) div 2;
        NH:=(Height - ExtentHeight);

      end;
    end;
    CheckMagick(MagickExtentImage(FMagickWand, ExtentWidth, ExtentHeight, NW, NH),'MagickExtentImage');

    DestroyPixelWand(PW1);

  end;
end;

function TipImageMagickLiteBitmap.ToBytes(AFormat: TipImageFormat;
  AQuality: Byte): TBytes;
const
  FORMAT_EXTENSIONS: array[TipImageFormat] of string = ('gif', 'bmp', 'png', 'tiff', 'jpg');
var
  LData: PByte;
  LDataLength: Cardinal;
begin
  SetLength(Result, 0);
  if not Assigned(FMagickWand) then
    Exit;
  CheckMagick(MagickSetImageCompressionQuality(FMagickWand, AQuality), 'TipImageMagickLiteBitmap.ToBytes');
  CheckMagick(MagickSetImageFormat(FMagickWand, PAnsiChar(AnsiString(FORMAT_EXTENSIONS[AFormat]))), 'TipImageMagickLiteBitmap.ToBytes');
  LData := MagickGetImagesBlob(FMagickWand, @LDataLength);
  if (LData <> nil) and (LDataLength > 0) then
  begin
    SetLength(Result, LDataLength);
    Move(LData^, Result[0], LDataLength);
  end;
end;

class function TipImageMagickLiteBitmap.TryInitializeLibrary: Boolean;
begin
  Result := TryInitializeImageMagick('C:\Program Files (x86)\ImageMagick-7.1.1-Q16\');
end;


{$ELSE}
implementation
{$ENDIF}
end.
