package net.digitalprimates.collections
{

import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

import mx.collections.ICollectionView;
import mx.collections.ListCollectionView;
import mx.core.mx_internal;

use namespace mx_internal;

[DefaultProperty("source")]

public class VectorListCollection extends ListCollectionView implements ICollectionView, IExternalizable
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  <p>Creates a new ArrayCollection using the specified source array.
     *  If no array is specified an empty array will be used.</p>
     */
    public function VectorListCollection(source:* = null)
    {
        super();

        this.source = source;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  source
    //----------------------------------

    [Inspectable(category="General", arrayType="Object")]
    [Bindable("listChanged")] //superclass will fire this

    /**
     *  The source of data in the ArrayCollection.
     *  The ArrayCollection object does not represent any changes that you make
     *  directly to the source array. Always use
     *  the ICollectionView or IList methods to modify the collection.
     */
    public function get source():*
    {
        if (list && (list is VectorList))
        {
            return VectorList(list).source;
        }
        return null;
    }

    /**
     *  @private
     */
    public function set source(s:*):void
    {
        list = new VectorList(s);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Ensures that only the source property is serialized.
     */
    public function readExternal(input:IDataInput):void
    {
        if (list is IExternalizable)
            IExternalizable(list).readExternal(input);
        else
            source = input.readObject() as Array;
    }

    /**
     *  @private
     *  Ensures that only the source property is serialized.
     */
    public function writeExternal(output:IDataOutput):void
    {
        if (list is IExternalizable)
            IExternalizable(list).writeExternal(output);
        else
            output.writeObject(source);
    }

}

}
