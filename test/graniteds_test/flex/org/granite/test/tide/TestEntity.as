/**
 * Generated by Gas3 v1.1.0 (Granite Data Services) on Sat Jul 26 17:58:20 CEST 2008.
 *
 * WARNING: DO NOT CHANGE THIS FILE. IT MAY BE OVERRIDDEN EACH TIME YOU USE
 * THE GENERATOR. CHANGE INSTEAD THE INHERITED CLASS (AbstractEntity.as).
 */

package org.granite.test.tide {

    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import flash.utils.IExternalizable;
    
    import org.granite.collections.IPersistentCollection;
    import org.granite.meta;
    import org.granite.ns.tide;
    import org.granite.tide.IEntityManager;
    import org.granite.tide.IPropertyHolder;

    use namespace meta;
    use namespace tide;


    [Managed]
    public class TestEntity implements IExternalizable {

		[Transient]
        meta var entityManager:IEntityManager = null;

        private var __initialized:Boolean = true;
        private var __detachedState:String = null;

        private var _id:Number;
        private var _uid:String;
        private var _version:Number;

        meta function isInitialized(name:String = null):Boolean {
            if (!name)
                return __initialized;

            var property:* = this[name];
            return (
                (!(property is AbstractEntity) || (property as AbstractEntity).meta::isInitialized()) &&
                (!(property is IPersistentCollection) || (property as IPersistentCollection).isInitialized())
            );
        }
        // Used only for testing
        meta function setInitialized(init:Boolean):void {
        	__initialized = init;
        }
		meta function set detachedState(state:String):void {
			__detachedState = state;
		}
		meta function get detachedState():String {
			return __detachedState;
		}
        meta function defineProxy3(obj:* = null):Boolean {
			if (obj != null) {
				var src:TestEntity = TestEntity(obj);
				if (src.__detachedState == null)
					return false;
				_id = src._id;
				__detachedState = src.__detachedState;
			}
			__initialized = false;
			return true;
        }

		[Id]
		[Bindable(event="unused")]
        public function get id():Number {
            return _id;
        }

        public function set uid(value:String):void {
            _uid = value;
        }
        public function get uid():String {
            return _uid;
        }

		[Version]
		[Bindable(event="unused")]
        public function get version():Number {
            return _version;
        }
		
		[Bindable(event="dirtyChange")]
		public function get meta_dirty():Boolean {
			return entityManager ? entityManager.meta_isEntityChanged(this) : true;
		}
        
		
		public function TestEntity(id:Number, version:Number, uid:String):void {
			_id = id;
			_version = version;
			_uid = uid;
		}
		

        meta function merge(em:IEntityManager, obj:*):void {
            var src:TestEntity = TestEntity(obj);
            __initialized = src.__initialized;
            __detachedState = src.__detachedState;
            if (meta::isInitialized()) {
	            em.meta_mergeExternal(src._id, _id, null, this, 'id', function setter(o:*):void{_id = o as Number});
	            em.meta_mergeExternal(src._uid, _uid, null, this, 'uid', function setter(o:*):void{_uid = o as String});
	            em.meta_mergeExternal(src._version, _version, null, this, 'version', function setter(o:*):void{_version = o as Number});
            }
            else {
               	em.meta_mergeExternal(src._id, _id, null, this, 'id', function setter(o:*):void{_id = o as Number});
            }
        }

        public function readExternal(input:IDataInput):void {
            __initialized = input.readObject() as Boolean;
            __detachedState = input.readObject() as String;
            if (meta::isInitialized()) {
                _id = function(o:*):Number { return (o is Number ? o as Number : Number.NaN) } (input.readObject());
                _uid = input.readObject() as String;
                _version = function(o:*):Number { return (o is Number ? o as Number : Number.NaN) } (input.readObject());
            }
            else {
                _id = function(o:*):Number { return (o is Number ? o as Number : Number.NaN) } (input.readObject());
            }
        }

        public function writeExternal(output:IDataOutput):void {
            output.writeObject(__initialized);
            output.writeObject(__detachedState);
            if (meta::isInitialized()) {
                output.writeObject((_id is IPropertyHolder) ? IPropertyHolder(_id).object : _id);
                output.writeObject((_uid is IPropertyHolder) ? IPropertyHolder(_uid).object : _uid);
                output.writeObject((_version is IPropertyHolder) ? IPropertyHolder(_version).object : _version);
            }
            else {
                output.writeObject(_id);
            }
        }
    }
}