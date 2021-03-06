/* Copyright (c) 2011, PIA. All rights reserved.
 *
 * This file is part of Eskimo.
 *
 * Eskimo is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Eskimo is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Eskimo.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.imrahil.mobile.twitfav.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.StageOrientationEvent;
    import flash.events.TextEvent;
    import flash.system.Capabilities;
    import flash.text.StyleSheet;
    import flash.ui.Keyboard;

    import flashx.textLayout.conversion.TextConverter;

    import mx.core.FlexGlobals;
    import mx.core.IFlexDisplayObject;
    import mx.events.CloseEvent;
    import mx.events.FlexEvent;
    import mx.managers.ISystemManager;
    import mx.managers.PopUpManager;

    import spark.components.Button;
    import spark.components.Group;
    import spark.components.Label;
    import spark.components.TextArea;
    import spark.components.supportClasses.SkinnableComponent;
    import spark.components.supportClasses.StyleableTextField;

    /**
     * Evant dispatched when the Alert is closed
     * @eventType mx.events.CloseEvent.CLOSE
     */
    [Event(name="close", type="mx.events.CloseEvent")]

    [Event(name="link", type="flash.events.TextEvent")]

    /**
     * Define the chrome background color the Alert comtrol
     * @defaults ios: 0x031037, android: 0x424242
     */
    [Style(name="backgroundColor", inherit="no", type="uint")]

    /**
     * Define the chrome background alpha the Alert comtrol
     * @defaults 0.9
     */
    [Style(name="backgroundAlpha", inherit="no", type="uint")]

    /**
     * Style of the OK button
     * @defaults "okButtonStyle"
     */
    [Style(name="okButtonStyleName", inherit="no", type="String")]
    /**
     * Style of the CANCEL button
     * @defaults "cancelButtonStyle"
     */
    [Style(name="cancelButtonStyleName", inherit="no", type="String")]
    /**
     * Style of the YES button
     * @defaults "yesButtonStyle"
     */
    [Style(name="yesButtonStyleName", inherit="no", type="String")]
    /**
     * Style of the NO button
     * @defaults "noButtonStyle"
     */
    [Style(name="noButtonStyleName", inherit="no", type="String")]

    /**
     * This component allow the user to display an Alert.
     * It automatically uses iOS or Android 's style depending to the execution platform.
     *
     * It follows the mx.controls.Alert 's behavior.
     */
    public class SkinnableAlert extends SkinnableComponent
    {
        /**
         *  Value that enables a OK button on the Alert control
         */
        public static const OK:uint = 0x0004;
        /**
         *  Value that enables a Cancel button on the Alert control
         */
        public static const UNFAV:uint = 0x0008;
        /**
         *  Value that remove modal background
         */
        public static const NONMODAL:uint = 0x8000;

        /**
         *  A bitmask that contains <code>SkinnableAlert.OK</code>, <code>SkinnableAlert.CANCEL</code>,
         *  <code>SkinnableAlert.YES</code>, and/or <code>SkinnableAlert.NO</code> indicating
         *  the buttons available in the SkinnableAlert control.
         */
        public var buttonFlags:uint = OK;

        /**
         * @private
         */
        public var buttonFlagsChanged:Boolean = true;

        /**
         * @private
         */
        protected var _text:String;
        /**
         * @private
         */
        protected var _title:String;

        /**
         * Title skin part
         */
        [SkinPart(required="false")]
        public var titleDisplay:Label;

        /**
         * Text skin part
         */
        [SkinPart(required="false")]
        public var textDisplay:TextArea;

        /**
         * Control bar group skin part
         */
        [SkinPart(required="false")]
        public var controlBarGroup:Group;

        /**
         * @private
         */
        protected var buttonOK:Button = new Button();
        /**
         * @private
         */
        protected var buttonUnfav:Button = new Button();


        /**
         * @private
         */
        protected static var _okLabel:String = "OK";
        /**
         * @private
         */
        protected static var _unFavLabel:String = "Unfav";
        /**
         * @private
         */
        protected static var _buttonHeight:Number = 50;

        protected var currentOS:String;

        protected var isIOS:Boolean;


        /**
         * Constructor
         */
        public function SkinnableAlert()
        {
            buttonOK = new Button();
            buttonUnfav = new Button();

            buttonOK.addEventListener(MouseEvent.CLICK, onOKClick);
            buttonUnfav.addEventListener(MouseEvent.CLICK, onUnfavClick);

            buttonOK.percentWidth = 100;
            buttonUnfav.percentWidth = 100;

            buttonOK.percentHeight = 100;
            buttonUnfav.percentHeight = 100;

            buttonOK.label = _okLabel;
            buttonUnfav.label = _unFavLabel;

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
            addEventListener(Event.REMOVED_FROM_STAGE, removeFromStage, false, 0, true);

            currentOS = Capabilities.version.toLocaleUpperCase();
            isIOS = currentOS.lastIndexOf("IOS") != -1;

        }

        protected function onAddedToStage(event:Event):void
        {
            systemManager.getSandboxRoot().addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);

            stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange, false, 0, true);
        }

        /**
         * @private
         */
        protected function removeFromStage(event:Event):void
        {
            systemManager.getSandboxRoot().removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

            stage.removeEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
        }

        /**
         * @private
         */
        protected function onOrientationChange(event:Event):void
        {
            invalidateDisplayList();
        }

        /**
         * @private
         */
        protected override function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            if (instance == controlBarGroup)
            {
                controlBarGroup.height = _buttonHeight;
                controlBarGroup.removeAllElements();

                if (buttonFlags & SkinnableAlert.OK)
                {
                    controlBarGroup.addElementAt(buttonOK, isIOS ? 0 : controlBarGroup.numChildren);
                }
                if (buttonFlags & SkinnableAlert.UNFAV)
                {
                    controlBarGroup.addElementAt(buttonUnfav, isIOS ? 0 : controlBarGroup.numChildren);
                }
            }
            if (instance == titleDisplay)
            {
                titleDisplay.text = _title;
            }
            if (instance == textDisplay)
            {
                textDisplay.addEventListener(TextEvent.LINK, onLinkClick);
                StyleableTextField(textDisplay.textDisplay).htmlText = _text;

                callLater(function():void
                {
                    var myStyleSheet:StyleSheet = new StyleSheet();
                    myStyleSheet.parseCSS("a {color: #b7c0e1; text-decoration: underline;}");
                    StyleableTextField(textDisplay.textDisplay).styleSheet = myStyleSheet;
                });
            }
        }

        private function onLinkClick(event:TextEvent):void
        {
            dispatchEvent(event);
        }

        /**
         * @private
         */
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (buttonFlagsChanged)
            {
                if (controlBarGroup)
                {
                    controlBarGroup.removeAllElements();
                    if (buttonFlags & SkinnableAlert.OK)
                    {
                        controlBarGroup.addElementAt(buttonOK, isIOS ? 0 : controlBarGroup.numChildren);
                    }
                    if (buttonFlags & SkinnableAlert.UNFAV)
                    {
                        controlBarGroup.addElementAt(buttonUnfav, isIOS ? 0 : controlBarGroup.numChildren);
                    }
                }

                buttonFlagsChanged = false;

                buttonOK.styleName = getStyle("okButtonStyleName");
                buttonUnfav.styleName = getStyle("noButtonStyleName");
            }

            PopUpManager.centerPopUp(this);
        }

        /**
         * @private
         */
        override protected function commitProperties():void
        {
            super.commitProperties();

            if (textDisplay)
            {
                StyleableTextField(textDisplay.textDisplay).htmlText = _text;
            }
        }

        /**
         * Create and show an Alert control
         * @param text     Text showed in the Alert control
         * @param title    Title of the Alert control
         * @param flags    A bitmask that contains <code>SkinnableAlert.OK</code>, <code>SkinnableAlert.CANCEL</code>,
         *                 <code>SkinnableAlert.YES</code>, and/or <code>SkinnableAlert.NO</code> indicating
         *                 the buttons available in the SkinnableAlert control.
         * @param closeHandler  Close function callback
         *
         */
        public static function show(text:String = "", title:String = "", flags:uint = 0x4, parent:Sprite = null, closeHandler:Function = null):SkinnableAlert
        {
            var modal:Boolean = (flags & SkinnableAlert.NONMODAL) ? false : true;

            if (!parent)
            {
                var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
                // no types so no dependencies
                var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
                if (mp && mp.useSWFBridge())
                {
                    parent = Sprite(sm.getSandboxRoot());
                }
                else
                {
                    parent = Sprite(FlexGlobals.topLevelApplication);
                }
            }


            var alert:SkinnableAlert = new SkinnableAlert();

            if (flags & SkinnableAlert.OK || flags & SkinnableAlert.UNFAV)
            {
                alert.buttonFlags = flags;
            }

            alert.text = text;
            alert.title = title;

            if (closeHandler != null)
            {
                alert.addEventListener(CloseEvent.CLOSE, closeHandler);
            }

            alert.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);


            PopUpManager.addPopUp(alert, parent, modal);

            return alert;
        }

        /**
         * @private
         */
        protected static function onCreationComplete(event:FlexEvent):void
        {
            PopUpManager.centerPopUp(event.target as IFlexDisplayObject);
        }

        /**
         * Text of the SkinnableAlert control
         */
        public function get text():String
        {
            return _text;
        }

        /**
         * @private
         */
        public function set text(value:String):void
        {
            _text = value;
        }

        /**
         * Title of the SkinnableAlert control
         */
        public function get title():String
        {
            return _title;
        }

        /**
         * @private
         */
        public function set title(value:String):void
        {
            _title = value;
        }

        /**
         * Label of the OK button
         */
        public static function get okLabel():String
        {
            return _okLabel;
        }

        /**
         * @private
         */
        public static function set okLabel(value:String):void
        {
            _okLabel = value;
        }

        /**
         * Label of the NO button
         */
        public static function get unFavLabel():String
        {
            return _unFavLabel;
        }

        /**
         * @private
         */
        public static function set unFavLabel(value:String):void
        {
            _unFavLabel = value;
        }

        /**
         * Buttons height
         */
        public static function get buttonHeight():Number
        {
            return _buttonHeight;
        }

        /**
         * @private
         */
        public static function set buttonHeight(value:Number):void
        {
            _buttonHeight = value;
        }

        /**
         * @private
         */
        protected function onOKClick(event:MouseEvent):void
        {
            dispatchEvent(new CloseEvent(CloseEvent.CLOSE, false, false, SkinnableAlert.OK));
            PopUpManager.removePopUp(this);
        }

        /**
         * @private
         */
        protected function onUnfavClick(event:MouseEvent):void
        {
            dispatchEvent(new CloseEvent(CloseEvent.CLOSE, false, false, SkinnableAlert.UNFAV));
            PopUpManager.removePopUp(this);
        }

        /**
         * @private
         */
        protected override function measure():void
        {
            super.measure();

//            measuredMinWidth = 300;
//            measuredMinHeight = 150;

            measuredWidth = FlexGlobals.topLevelApplication.width - (FlexGlobals.topLevelApplication.width * 0.4);

            textDisplay.width = measuredWidth - 20;
        }

        /**
         * @private
         */
        protected function onKeyDown(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.BACK)
            {
                event.preventDefault();
            }
        }
    }
}
