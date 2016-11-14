//
//  ORCropImageViewController.swift
//  InMusik Explorer
//
//  Created by Admin on 3/2/16.
//  Copyright © 2016 Stone Valley Partners. All rights reserved.
//

import UIKit
import QuartzCore


public protocol ORCropImageViewControllerDelegate {
    func titleForCropVCSubmitButton() -> String
    func titleForCropVCCancelButton() -> String
    func usingButtonsInCropVC() -> ORCropImageViewController.Button
    
    func cropVCDidFailToPrepareImage(error: NSError?)
    func cropVCDidFinishCrop(withImage image: UIImage?)
}

public protocol ORCropImageViewControllerDownloadDelegate {
    func downloadImage(fromURL url: NSURL, completion: (image: UIImage?, error: NSError?) -> Void);
}

public class ORCropImageViewController: UIViewController, UIScrollViewDelegate {

    //MARK: - Struct
    
    public struct Button : OptionSetType {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static public let Submit = Button(rawValue: 1)
        static public let Cancel = Button(rawValue: 2)
    }
    
    
    //MARK: - Enumerations
    
    public enum CursorType {
        case None
        case Circle
        case RoundedRect
    }
    
    
    //MARK: - Constants
    
    let kRoundedRectCornerRadius: CGFloat = 3.0
    let kRoundedRectHeightRatio: CGFloat = 0.72
    let kFrameNormalOffset: CGFloat = 8.0
    let kButtonsPanelHeight: CGFloat = 52.0
    
    
    //MARK: - Variables
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    weak var ivImage: UIImageView!
    
    @IBOutlet weak var circleFrameView: UIView!
    
    @IBOutlet weak var lyocCursorViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lyocCursorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lyocScrollViewBottomOffset: NSLayoutConstraint!
    
    var croppedImageCallback: ((image: UIImage?) -> Void)?;
    
    var shadeLayer: CALayer?;
    
    var shouldAddShadeLayer: Bool = true;
    public var srcImage: UIImage!;
    public var destImageMaxSize: CGSize?
    
    public var cursorType: CursorType = CursorType.None
    public var delegate: ORCropImageViewControllerDelegate?
    public var downloadDelegate: ORCropImageViewControllerDownloadDelegate? = ORCropImageViewControllerDefaultDownloadDelegate()
    
    
    //MARK: - Initializers
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(nibName: String?, bundle: NSBundle?, image: UIImage) {
        self.init(nibName: nibName, bundle: bundle)
        self.srcImage = image
    }
    
    convenience public init(nibName: String?, bundle: NSBundle?, imageURL url: NSURL) {
        self.init(nibName: nibName, bundle: bundle)
        setupImageFromURL(url)
    }
    
    convenience public init(nibName: String?, bundle: NSBundle?, imageURLPath path: String) {
        guard let url = NSURL(string: path) else {
            self.init(nibName: nibName, bundle: bundle)
            
            ORCropImageViewController.log("Failed to initialize. Reason: Invalid URL string")
            
            onFail(withMessage: "Invalid URL string")
            
            return
        }
        
        self.init(nibName: nibName, bundle: bundle, imageURL: url)
    }
    
    
    //MARK: - Lifecycle
    
    static public func defaultViewController() -> ORCropImageViewController {
        return ORCropImageViewController(nibName: "ORCropImageViewController", bundle: NSBundle(forClass: ORCropImageViewController.self))
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.lyocScrollViewBottomOffset.constant = (cursorType == .None) ? 0.0 : kButtonsPanelHeight
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        self.fillUI();
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        setupUI()
        fillUI()
    }
    
    
    //MARK: - Setup
    
    public func setupImageFromURL(url: NSURL) {
        guard let dlDelegate = downloadDelegate else {
            onFail(withMessage: "Download delegate is not set!")
            return
        }
        
        dlDelegate.downloadImage(fromURL: url) { [weak self] (image, error) in
            if let srcImage = image {
                self?.srcImage = srcImage
                self?.setupUI()
                self?.fillUI()
            } else {
                self?.delegate?.cropVCDidFailToPrepareImage(error)
            }
        }
    }
    
    func setupUI() {
        prepareCursorView();
        prepareShadeLayer();
        prepareScrollView();
        prepareBottomBarButtons()
    }
    
    func prepareBottomBarButtons() {
        let usingButtons = delegate?.usingButtonsInCropVC() ?? [.Submit, .Cancel]
        
        if usingButtons.contains(.Submit) && srcImage != nil && cursorType != .None {
            let title = delegate?.titleForCropVCSubmitButton() ?? NSLocalizedString("Save", comment: "")
            btnSubmit.setTitle(title, forState: UIControlState.Normal)
            btnSubmit.hidden = false
        } else {
            btnSubmit.hidden = true
        }
        
        if usingButtons.contains(.Cancel) {
            let title = delegate?.titleForCropVCCancelButton() ?? NSLocalizedString("Cancel", comment: "")
            btnCancel.setTitle(title, forState: UIControlState.Normal)
            btnCancel.hidden = false
        } else {
            btnCancel.hidden = true
        }
    }
    
    func prepareShadeLayer() {
        self.shadeLayer?.removeFromSuperlayer();
        
        self.circleFrameView.hidden = (cursorType == CursorType.None)
        self.shadeView.hidden = self.circleFrameView.hidden
        
        switch cursorType {
        case .RoundedRect:
            var frameWidth: CGFloat = 0.0
            var frameHeight: CGFloat = 0.0
            
            if self.view.frame.size.width < self.view.frame.size.height {
                frameWidth = self.view.frame.size.width - kFrameNormalOffset * 2
                frameHeight = frameWidth * kRoundedRectHeightRatio
            } else {
                frameHeight = self.view.frame.size.height - (kFrameNormalOffset + kButtonsPanelHeight)
                frameWidth = frameHeight / kRoundedRectHeightRatio
            }
            
            self.shadeLayer = roundedRectShadeLayer()
            self.shadeLayer!.frame = CGRect(origin: CGPointZero, size: CGSize(width: frameWidth, height: frameHeight));
        case .Circle:
            self.shadeLayer = circleShadeLayer();
            self.shadeLayer!.frame = self.shadeView.bounds;
        default: break
        }
        
        if self.shadeLayer != nil {
            self.shadeView.layer.addSublayer(self.shadeLayer!);
        }
    }
    
    func prepareScrollView() {
        
        if cursorType != .None {
            let bottomInset: CGFloat = self.view.frame.size.height - CGRectGetMaxY(self.circleFrameView.frame) - kButtonsPanelHeight;
            let rightInset: CGFloat = self.view.frame.size.width - CGRectGetMaxX(self.circleFrameView.frame);
            
            self.scrollView.contentInset = UIEdgeInsets(top: self.circleFrameView.frame.origin.y, left: self.circleFrameView.frame.origin.x, bottom: bottomInset, right: rightInset);
        } else {
            self.scrollView.contentInset = UIEdgeInsetsZero
        }
    }
    
    func prepareCursorView() {
        
        switch cursorType {
        case .RoundedRect:
            
            var frameWidth: CGFloat = 0.0
            var frameHeight: CGFloat = 0.0
            
            if self.view.frame.size.width < self.view.frame.size.height {
                frameWidth = self.view.frame.size.width - kFrameNormalOffset * 2.0
                frameHeight = frameWidth * kRoundedRectHeightRatio
            } else {
                frameHeight = self.view.frame.size.height - (kFrameNormalOffset + kButtonsPanelHeight)
                frameWidth = frameHeight / kRoundedRectHeightRatio
            }
           
            self.circleFrameView.layer.cornerRadius = kRoundedRectCornerRadius
            self.circleFrameView.frame = CGRect(origin: CGPointZero, size: CGSize(width: frameWidth, height: frameHeight))
            
            self.lyocCursorViewWidth.constant = frameWidth
            self.lyocCursorViewHeight.constant = frameHeight
        default:
            var minSideSize = min(self.view.frame.size.width, self.view.frame.size.height - kButtonsPanelHeight)
            minSideSize -= 16.0
            
            self.circleFrameView.layer.cornerRadius = minSideSize * 0.5;
            self.circleFrameView.frame = CGRect(origin: CGPointZero, size: CGSize(width: minSideSize, height: minSideSize))
            self.lyocCursorViewWidth.constant = minSideSize
            self.lyocCursorViewHeight.constant = minSideSize
        }
        
        self.circleFrameView.center = CGPointMake(self.view.frame.size.width * 0.5, (self.view.frame.size.height - kButtonsPanelHeight) * 0.5)
        self.circleFrameView.layer.borderColor = UIColor.whiteColor().CGColor;
        self.circleFrameView.layer.borderWidth = 2.0;
    }
    
    func fillUI() {
        if self.srcImage == nil {
            return
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false;
        
        var imageScale: CGFloat = 1.0
        var minimalScale: CGFloat = 1.0
        
        if (cursorType != .None) {
            let scaleX = circleFrameView.frame.size.width / srcImage.size.width
            let scaleY = circleFrameView.frame.size.height / srcImage.size.height
            
            let maxSideScale: CGFloat = max(scaleX, scaleY)
            imageScale = maxSideScale
            minimalScale = imageScale
        } else {
            imageScale = self.view.frame.size.height / srcImage.size.height
            minimalScale = self.view.frame.size.width / srcImage.size.width
        }
        
        let scrollContentSize: CGSize = CGSize(width: srcImage.size.width, height: srcImage.size.height);
        
        self.scrollView.minimumZoomScale = minimalScale;
        self.scrollView.zoomScale = 1.0;
        self.scrollView.contentSize = scrollContentSize;
        
        if self.ivImage != nil {
            self.ivImage.removeFromSuperview()
        }
        
        let ivImage: UIImageView = UIImageView(image: srcImage);
        ivImage.frame = CGRect(origin: CGPointZero, size: scrollContentSize);
        ivImage.center = CGPoint(x: scrollView.contentSize.width * 0.5, y: scrollView.contentSize.height * 0.5);
        
        self.scrollView.addSubview(ivImage);
        self.ivImage = ivImage;
        
        self.scrollView.zoomScale = imageScale;
    }
    
    //MARK: - Internal operations
    
    func circleShadeLayer() -> CALayer {
        
        let maskFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        let circleFrame: CGRect = CGRect(x: self.circleFrameView.frame.origin.x, y: self.circleFrameView.frame.origin.y,
            width: self.circleFrameView.frame.size.width, height: self.circleFrameView.frame.size.height);
        
        let radius: CGFloat = circleFrame.size.width * 0.5;
        let path: UIBezierPath = UIBezierPath(rect: maskFrame);
        let circlePath: UIBezierPath = UIBezierPath(roundedRect:circleFrame, cornerRadius:radius);
        
        path.appendPath(circlePath);
        
        path.usesEvenOddFillRule = true;
        
        let fillLayer: CAShapeLayer = CAShapeLayer();
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = UIColor(white: 0.0, alpha: 0.75).CGColor;
        fillLayer.opacity = 1.0;

        return fillLayer;
    }
    
    func roundedRectShadeLayer() -> CALayer {
        
        let frameHeight: CGFloat = self.circleFrameView.frame.size.width * kRoundedRectHeightRatio
        
        let maskFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        let rectFrame: CGRect = CGRect(x: self.circleFrameView.frame.origin.x, y: self.circleFrameView.frame.origin.y,
                                         width: self.circleFrameView.frame.size.width, height: frameHeight);
        
        let path: UIBezierPath = UIBezierPath(rect: maskFrame);
        let circlePath: UIBezierPath = UIBezierPath(roundedRect:rectFrame, cornerRadius:kRoundedRectCornerRadius);
        
        path.appendPath(circlePath);
        
        path.usesEvenOddFillRule = true;
        
        let fillLayer: CAShapeLayer = CAShapeLayer();
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = UIColor(white: 0.0, alpha: 0.75).CGColor;
        fillLayer.opacity = 1.0;
        
        return fillLayer;
    }
    
    func croppedImage() -> UIImage? {
        
        guard self.ivImage.image != nil else {
            return nil;
        }
        
        let cropRect: CGRect = CGRect(x: (scrollView.contentOffset.x + scrollView.contentInset.left) / scrollView.zoomScale,
                                      y: (scrollView.contentOffset.y + scrollView.contentInset.top) / scrollView.zoomScale,
                                      width: circleFrameView.frame.size.width / scrollView.zoomScale,
                                      height: circleFrameView.frame.size.height / scrollView.zoomScale);
        
        UIGraphicsBeginImageContext(self.srcImage.size);
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext()!, 0.5 * self.srcImage.size.width, 0.5 * self.srcImage.size.height);
        self.srcImage.drawInRect(CGRect(origin: CGPointMake(-self.srcImage.size.width * 0.5, -self.srcImage.size.height * 0.5), size: self.srcImage.size));
        
        let normalImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let cgImage: CGImageRef = CGImageCreateWithImageInRect(normalImage.CGImage!, cropRect)!;
        let croppedImage: UIImage = UIImage(CGImage: cgImage);
        var requiredScale: CGFloat = 1.0
        
        if let maxSize = self.destImageMaxSize {
            if croppedImage.size.width > croppedImage.size.height {
                requiredScale = maxSize.width / croppedImage.size.width
            } else {
                requiredScale = maxSize.height / croppedImage.size.height
            }
        }
        
        var scaledImageRect = CGRect(origin: CGPointZero, size: croppedImage.size)
        
        if requiredScale < 1.0 {
            let scaledImageWidth = croppedImage.size.width * requiredScale
            let scaledImageHeight = croppedImage.size.height * requiredScale
            scaledImageRect = CGRect(origin: CGPointZero, size: CGSize(width: scaledImageWidth, height: scaledImageHeight))
        }
        
        UIGraphicsBeginImageContext(scaledImageRect.size);

        //CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.5 * scaledImageRect.size.width, 0.5 * scaledImageRect.size.height);
        croppedImage.drawInRect(scaledImageRect);
        
        let resultImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let resultImageSize = resultImage.size
        print(resultImageSize)
        
        return croppedImage;
    }
    
    
    //MARK: - Actions
    
    @IBAction func onChooseButtonTouchUp(sender: AnyObject) {
        
        if croppedImageCallback != nil {
            croppedImageCallback!(image: croppedImage());
        }
        
        delegate?.cropVCDidFinishCrop(withImage: croppedImage())
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func onCancelButtonTouchUp(sender: AnyObject) {
    
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return ivImage;
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        self.ivImage.transform = CGAffineTransformMakeScale(scrollView.zoomScale, scrollView.zoomScale);
        self.ivImage.center = CGPoint(x: scrollView.contentSize.width * 0.5, y: scrollView.contentSize.height * 0.5);
        
        if cursorType == .None {
            let verticalInset = (self.view.frame.size.height - self.ivImage.frame.size.height) * 0.5
            
            if verticalInset >= 0.0 {
                scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: 0.0, bottom: verticalInset, right: 0.0)
            }
        }
    }
    
    
    //MARK: - Helpers
    
    static func log(msg: String) {
        print("[Crop Image VC]: \(msg)")
    }
    
    func onFail(withMessage msg: String) {
        let userInfo: [NSObject : AnyObject] = [kCFErrorLocalizedDescriptionKey : msg]
        let error = NSError(domain: "url_error", code: -1, userInfo: userInfo)
        delegate?.cropVCDidFailToPrepareImage(error)
    }
}
